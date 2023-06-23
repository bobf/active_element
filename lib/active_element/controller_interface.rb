# frozen_string_literal: true

module ActiveElement
  # Provides the `active_element` object available on all controller instance/class methods.
  # Encapsulates core functionality such as `authenticate_with`, `permit_action`, and `component`
  # without polluting application controller namespace.
  class ControllerInterface
    attr_reader :missing_template_store, :current_user, :assigned_editable_fields

    @state = {}

    class << self
      attr_reader :state
    end

    def initialize(controller_class, controller_instance = nil)
      @controller_class = controller_class
      @controller_instance = controller_instance
      initialize_state(controller_class)
      @missing_template_store = {}
      @authorize = false
    end

    def authorize?
      @authorize
    end

    def listable_fields(*args, order: nil)
      state.list_order = order
      state.listable_fields.concat(args.map(&:to_sym)).uniq!
    end

    def viewable_fields(*args)
      state.viewable_fields.concat(args.map(&:to_sym)).uniq!
    end

    def editable_fields(*args)
      state.editable_fields.concat(args.map(&:to_sym)).uniq!
    end

    def searchable_fields(*args, required: false)
      state.search_required = required
      state.searchable_fields.concat(args.map(&:to_sym)).uniq!
    end

    def deletable
      state.deletable = true
    end

    def application_name
      RailsComponent.new(::Rails).application_name
    end

    def t(identifier, **kwargs)
      ::I18n.t("active_element.#{identifier}", **kwargs)
    end

    def authenticate_with(&block)
      state.authenticator = block
    end

    def authorize_with(&block)
      @authorize = true
      state.authorizor = block
    end

    def sign_out_with(method: :get, &block)
      state.sign_out_method = method
      state.sign_out_path = block
    end

    def sign_out_path
      state.sign_out_path&.call
    end

    delegate :sign_out_method, to: :state

    def sign_in_with(method: :get, &block)
      state.sign_in_method = method
      state.sign_in_path = block
    end

    def sign_in_path
      state.sign_in_path&.call
    end

    delegate :sign_in_method, to: :state

    def authenticate
      authenticator&.call
      @current_user = state.authorizor&.call

      nil
    end

    def permit_action(action, with: nil, always: false)
      raise ArgumentError, "Must specify `with: '<permission>'` or `always: true`" unless with.present? || always
      raise ArgumentError, 'Cannot specify both `with` and `always: true`' if with.present? && always

      state.permissions << { with: with, always: always, action: action }
    end

    delegate :authenticator, to: :state

    delegate :permissions, to: :state

    def component
      return (@component ||= ActiveElement::Component.new(controller_instance)) unless controller_instance.nil?

      raise ArgumentError, 'Attempted to use ActiveElement component from a controller class method.'
    end

    def state
      self.class.state[controller_class]
    end

    private

    attr_reader :controller_class, :controller_instance

    def initialize_state(key)
      self.class.state[key] ||= ControllerState.new(controller: controller_instance)
    end
  end
end
