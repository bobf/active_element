# frozen_string_literal: true

module ActiveElement
  # Processes all controller actions, verifies permissions, issues redirects, etc.
  class ControllerAction
    def initialize(controller)
      @controller = controller
    end

    def process_action
      Rails.logger.info("[#{log_tag}] #{colorized_permissions_message}")
      return if verified_permissions?

      warn "[#{log_tag}] #{colorized_permissions_message}" if Rails.env.test?
      return controller.redirect_to redirect_path if redirect_to_default_landing_page?

      render_forbidden
    end

    private

    attr_reader :controller

    def verified_permissions?
      return @verified_permissions if defined?(@verified_permissions)

      (@verified_permissions = permissions_check.permitted?)
    end

    def redirect_path
      routes.alternative_routes.first.path
    end

    def render_forbidden
      return render_json_forbidden if controller.request.format == :json

      controller.render 'active_element/forbidden',
                        layout: 'active_element_error',
                        status: :forbidden,
                        locals: {
                          missing_permissions: permissions_check.missing,
                          alternatives: routes.alternative_routes
                        }
    end

    def render_json_forbidden
      controller.render json: { message: "Missing permission(s): #{permissions_check.missing}" },
                        status: :forbidden
    end

    def permissions_check
      @permissions_check ||= PermissionsCheck.new(
        required: controller.class.active_element_permissions,
        actual: controller.current_user&.permissions,
        controller_path: controller.controller_path,
        action_name: controller.action_name,
        rails_component: rails_component
      )
    end

    def routes
      @routes ||= Routes.new(
        permissions: controller.current_user.permissions,
        rails_component: rails_component
      )
    end

    def colorized_permissions_message
      color = if permissions_check.permitted?
                :green
              else
                (rails_component.environment == 'test' ? :yellow : :red)
              end
      ColorizedString.new(permissions_check.message, color: color).value
    end

    def redirect_to_default_landing_page?
      return false if controller.request.format == :json

      controller.request.path == '/' && routes.alternative_routes.present?
    end

    def rails_component
      @rails_component ||= RailsComponent.new(::Rails)
    end

    def log_tag
      ColorizedString.new('ActiveElement', color: :cyan).value
    end
  end
end
