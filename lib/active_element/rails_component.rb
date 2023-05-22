# frozen_string_literal: true

module ActiveElement
  # Abstraction of various Rails interfaces.
  class RailsComponent
    def initialize(rails)
      @rails = rails
    end

    def routes
      rails.application.routes
    end

    def environment
      rails.env
    end

    def application_name
      rails.application.class.module_parent.name.underscore
    end

    # Provides array of e.g. { path: "/admin/users", controller: "admin/users", action: "index" }
    def route_paths_with_requirements
      rails.application.routes.routes.map do |route|
        { path: path_from_route_spec(route.path.spec) }.merge(route.requirements)
      end
    end

    private

    attr_reader :rails

    # Translates "/admin/users/:id(.:format)" into "/admin/users"
    def path_from_route_spec(spec)
      # FIXME: Find a more robust way of doing this ?
      path = spec.to_s.gsub(/:.*/, '').gsub(/\(.*/, '')
      path == '/' ? path : path.chomp
    end
  end
end
