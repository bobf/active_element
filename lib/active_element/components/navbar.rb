# frozen_string_literal: true

module ActiveElement
  module Components
    # A navigation bar providing links to areas within the application.
    class Navbar
      include Translations

      attr_reader :controller

      def initialize(controller, items: nil, fixed: true)
        @controller = controller
        @items = items
        @fixed = fixed
      end

      def template
        'active_element/components/navbar'
      end

      def locals
        {
          component: self,
          items: items,
          fixed: fixed
        }
      end

      def active_path_class(current_navbar_item:)
        if ActiveMenuLink.new(
          rails_component: RailsComponent.new(Rails),
          navbar_items: items,
          current_path: controller.request.path,
          current_navbar_item: current_navbar_item,
          controller_path: controller.controller_path,
          action_name: controller.action_name
        ).active?
          'active'
        end
      end

      private

      attr_reader :fixed

      def items
        return @items unless @items.nil?

        ActiveElement.eager_load_controllers

        @items ||= user_routes(controller.active_element.current_user).available.select(&:primary?).map do |route|
          { path: route.path, title: route.title, spec: route.spec }
        end.uniq { |item| item[:title] }
      end

      def user_routes(user)
        ActiveElement::Routes.new(
          permissions: user&.permissions,
          rails_component: ActiveElement::RailsComponent.new(Rails)
        )
      end
    end
  end
end
