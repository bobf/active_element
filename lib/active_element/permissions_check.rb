# frozen_string_literal: true

module ActiveElement
  # Verifies provided permissions against required permissions.
  class PermissionsCheck
    def initialize(required:, actual:, controller_path:, action_name:, rails_component:)
      @required = required.presence || []
      @actual = normalized(actual)
      @controller_name = controller_path.to_s.gsub('/', '_')
      @action_name = action_name.to_s
      @rails_component = rails_component
      raise_unprotected_route_error if applicable.empty?
    end

    def permitted?
      rails_component.environment == 'development' || missing.blank?
    end

    def message
      return development_environment_message if rails_component.environment == 'development'
      return "User access granted for permission(s): #{applicable.join(', ')}" if permitted?

      "User access forbidden. Missing user permission(s): #{missing.join(', ')}"
    end

    def missing
      @missing ||= applicable.reject do |permission|
        actual.include?(permission.to_s)
      end.map(&:to_s)
    end

    def applicable
      @applicable ||= default_permissions + required_permissions
    end

    private

    attr_reader :required, :actual, :controller_name, :action_name, :rails_component

    def development_environment_message
      "Bypassed permission(s) in development environment: #{applicable.join(', ')}"
    end

    def default_permissions
      return [] if normalized_action.nil?

      ["can_#{normalized_action}_#{rails_component.application_name}_#{controller_name}"]
    end

    def required_permissions
      @required_permissions ||= required.map do |permission, options|
        next nil unless applicable?(options)

        permission
      end.compact
    end

    def normalized_action
      {
        index: 'list',
        show: 'view',
        edit: 'edit',
        update: 'edit',
        create: 'create',
        new: 'create',
        destroy: 'delete'
      }.fetch(action_name.to_sym, nil)
    end

    def normalized(val)
      return val&.map(&:to_s) if val.is_a?(Array)

      [val].map(&:to_s)
    end

    def applicable?(options)
      return true if !options.key?(:only) && !options.key?(:except)
      return true if only_applicable?(options)
      return false if except_applicable?(options)

      false
    end

    def only_applicable?(options)
      return false unless options.key?(:only)

      normalized(options.fetch(:only)).include?(action_name)
    end

    def except_applicable?(options)
      return false unless options.key?(:except)

      normalized(options.fetch(:except)).include?(action_name)
    end

    def raise_unprotected_route_error
      raise UnprotectedRouteError,
            "#{controller_name.titleize.tr(' ', '')}##{action_name} must be protected with `permit_user`"
    end
  end
end
