# frozen_string_literal: true

module ActiveElement
  # Abstraction of a Rails route, includes path, permitted state (based on user permissions), etc.
  class Route
    include Comparable

    attr_reader :controller

    def initialize(controller:, required_permissions:, user_permissions:, action:, rails_component:)
      @controller = controller
      @required_permissions = required_permissions
      @user_permissions = user_permissions
      @action = action
      @rails_component = rails_component
    end

    def <=>(other)
      return 0 if path.nil? && other.path.nil?
      return 1 if path.nil?
      return -1 if other.path.nil?

      path <=> other.path
    end

    def permitted?
      return @permitted if defined?(@permitted)

      (@permitted = permitted_action?)
    end

    def path
      @path ||= rails_path
    end

    def primary?
      return false if rails_non_index_action?
      return false unless resourceless_get_request?
      return false if excluded_ancestor?

      true
    end

    def title
      controller.controller_name.titleize
    end

    def spec
      { controller: controller.controller_path, action: action.to_s }
    end

    def permissions
      permissions_check.applicable.map { |permission| permission.fetch(:with).to_s }
    end

    def rails_route?
      rails_application_route? || active_element_route?
    end

    private

    attr_reader :required_permissions, :user_permissions, :action, :rails_component

    def rails_application_route?
      rails_component.routes.routes.map(&:requirements).any? { |requirements| match_spec?(requirements) }
    end

    def active_element_route?
      ActiveElement::Engine.routes.routes.map(&:requirements).any? { |requirements| match_spec?(requirements) }
    end

    def match_spec?(requirements)
      requirements.to_set.superset?(spec.to_set)
    end

    def rails_path
      rails_component.routes.url_for(**spec, only_path: true)
    rescue ActionController::UrlGenerationError
      nil
    end

    def rails_non_index_action?
      %i[show edit update new create destroy].include?(action)
    end

    def resourceless_get_request?
      spec_set = spec.to_set
      rails_component.routes.routes.find do |rails_route|
        next false unless rails_route.requirements&.to_set&.superset?(spec_set)
        next false unless rails_route.verb == 'GET'
        next false unless rails_route.required_parts.empty?

        true
      end
    end

    def excluded_ancestor?
      ancestors = controller.class.ancestors.map(&:name)
      excluded_ancestors.any? { |excluded_ancestor| ancestors.include?(excluded_ancestor) }
    end

    def excluded_ancestors
      # This will likely end up a config setting, for now we exclude Devise so its controllers
      # don't appear in the Navbar.
      %w[DeviseController]
    end

    def permitted_action?
      permissions_check.permitted?
    rescue UnprotectedRouteError
      false
    end

    def permissions_check
      @permissions_check ||= PermissionsCheck.new(
        required: required_permissions,
        actual: user_permissions,
        controller_path: controller.controller_path,
        action_name: action,
        rails_component: rails_component
      )
    end
  end
end
