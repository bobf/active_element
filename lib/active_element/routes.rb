# frozen_string_literal: true

module ActiveElement
  # Provides an interface to available admin routes, used for populating a default navigation bar
  # and detecting available permitted routes if the default root path is not permitted.
  class Routes
    include Enumerable

    def initialize(rails_component:, permissions: [])
      @permissions = permissions
      @rails_component = rails_component
    end

    def permitted
      @permitted ||= available_routes.select(&:permitted?)
    end

    def available
      @available ||= available_routes
    end

    def alternative_routes
      @alternative_routes ||= available.select(&:primary?).reject { |route| route.path == '/' }
    end

    def each(&block)
      available.each(&block)
    end

    private

    attr_reader :permissions, :rails_component

    def available_routes
      @available_routes ||= descendants_with_permissions.map do |descendant, required_permissions|
        action_methods = descendant.public_methods(false)
        ([:index] + action_methods).uniq.map do |action|
          route(descendant, action, required_permissions)
        end
      end.flatten.compact.select(&:rails_route?).sort
    end

    def descendants_with_permissions
      @descendants_with_permissions ||= descendants.map do |controller_class|
        [controller_class.new, controller_class.active_element.permissions]
      end.compact
    end

    def descendants
      @descendants ||= ActiveElement::ApplicationController.descendants
    end

    def route(controller, action, required_permissions)
      Route.new(
        controller: controller,
        action: action,
        required_permissions: required_permissions,
        user_permissions: permissions,
        rails_component: rails_component
      )
    end
  end
end
