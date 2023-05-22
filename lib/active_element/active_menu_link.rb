# frozen_string_literal: true

module ActiveElement
  # Detects which link should be highlighted in the main application menu.
  class ActiveMenuLink
    # rubocop:disable Metrics/ParameterLists
    def initialize(rails_component:, current_path:, controller_path:, action_name:, current_navbar_item:, navbar_items:)
      @rails_component = rails_component
      @current_path = current_path
      @controller_path = controller_path
      @action_name = action_name
      @current_navbar_item = current_navbar_item
      @navbar_items = navbar_items
    end
    # rubocop:enable Metrics/ParameterLists

    def active?
      return true if exact_match?
      return true if !any_exact_match? && exact_without_query_string_match?
      return true if !any_exact_match? && !any_exact_without_query_string_match? && exact_without_resource_match?

      false
    end

    private

    attr_reader :rails_component,
                :current_path, :controller_path, :action_name,
                :current_navbar_item, :navbar_items

    def exact_match?(navbar_item = current_navbar_item)
      exact_matched_route(navbar_item)&.fetch(:path) == current_path
    end

    def exact_matched_route(navbar_item)
      rails_component.route_paths_with_requirements.find do |route_path_with_requirements|
        route_path_with_requirements[:path] == navbar_item[:path]
      end
    end

    def any_exact_match?
      navbar_items.any? do |navbar_item|
        exact_match?(navbar_item)
      end
    end

    def exact_without_query_string_match?(navbar_item = current_navbar_item)
      exact_matched_route_without_query_string(navbar_item)&.fetch(:path) == without_query_string(current_path)
    end

    def any_exact_without_query_string_match?
      navbar_items.any? do |navbar_item|
        exact_without_query_string_match?(navbar_item)
      end
    end

    def exact_matched_route_without_query_string(navbar_item)
      rails_component.route_paths_with_requirements.find do |route_path_with_requirements|
        route_path_with_requirements[:path] == without_query_string(navbar_item[:path])
      end
    end

    def without_query_string(path)
      path.rpartition('?').compact_blank.first
    end

    def exact_without_resource_match?
      route = exact_matched_route_without_resource(current_navbar_item)
      return false if route.blank?

      route[:controller] == controller_path
    end

    def exact_matched_route_without_resource(navbar_item)
      rails_component.route_paths_with_requirements.find do |route_path_with_requirements|
        navbar_item.dig(:spec, :controller) == route_path_with_requirements[:controller]
      end
    end
  end
end
