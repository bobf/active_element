# frozen_string_literal: true

module ActiveElement
  # Generates a report of all permissions used by a given application. Used by `rake active_element:permissions`
  # to provide a convenient interface to listing all required permissions so that they can be provisioned to
  # users as needed.
  class PermissionsReport
    include Paintbrush

    COLOR_MAP = { list: :cyan, view: :blue, create: :green, delete: :red, edit: :yellow, text: :white }.freeze

    def initialize
      ActiveElement.eager_load_controllers
      ActiveElement.eager_load_models
      @buffer = []
    end

    def report
      generate
      buffer.join("\n")
    end

    private

    attr_reader :buffer

    def generate
      buffer << paintbrush { blue "\nThe following user permissions are used by this application:\n" }
      permissions.each do |permission|
        buffer << paintbrush { white "    * #{public_send(color(permission), permission)}" }
      end
      buffer << "\n"
    end

    def color(permission)
      COLOR_MAP.find do |action, _|
        permission.include?("_#{action}_")
      end&.last || :purple
    end

    def permissions
      routes.map(&:permissions).flatten.sort.uniq + text_search_permissions
    end

    def text_search_permissions
      ActiveElement::Components::TextSearch.authorized_text_searches.map do |model, with, providing|
        (Array(with) + Array(providing)).map do |field|
          ActiveElement::Components::TextSearch::Authorization.permission_for(model: model, field: field)
        end
      end.flatten.uniq
    end

    def routes
      ActiveElement::Routes.new(rails_component: ActiveElement::RailsComponent.new(Rails))
    end
  end
end
