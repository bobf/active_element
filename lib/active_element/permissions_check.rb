# frozen_string_literal: true

module ActiveElement
  # Verifies provided permissions against required permissions.
  class PermissionsCheck
    include Paintbrush

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
      return permitted_message if permitted?

      forbidden_message
    end

    def missing
      @missing ||= applicable.reject do |permission|
        next true if permission.fetch(:always, false)

        actual.include?(permission.fetch(:with).to_s)
      end
    end

    def applicable
      @applicable ||= default_permissions + required_permissions
    end

    def applicable_permissions
      applicable.map { |permission| permission.fetch(:with) }
    end

    def missing_permissions
      missing.map { |permission| permission.fetch(:with) }
    end

    private

    attr_reader :required, :actual, :controller_name, :action_name, :rails_component

    def development_environment_message
      "Bypassed permission(s) in development environment: #{applicable_permissions.join(', ')}"
    end

    def permitted_message
      paintbrush { green "User access granted for permission(s): #{cyan applicable_permissions.join(', ')}" }
    end

    def forbidden_message
      paintbrush { red "User access forbidden. Missing user permission(s): #{cyan missing_permissions.join(', ')}" }
    end

    def default_permissions
      return [] if normalized_action.nil?

      [{
        action: normalized_action,
        with: "can_#{normalized_action}_#{rails_component.application_name}_#{controller_name}"
      }]
    end

    def required_permissions
      @required_permissions ||= required.select { |options| applicable?(options) }
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
      options.fetch(:action).to_s == action_name
    end

    def raise_unprotected_route_error
      raise UnprotectedRouteError,
            "#{controller_name.titleize.tr(' ', '')}##{action_name} must be protected with " \
            '`active_element.permit_action`'
    end
  end
end
