# frozen_string_literal: true

require 'faraday'
require 'rouge'
require 'kaminari'
require 'sassc'
require 'bootstrap'
require 'active_record'

require_relative 'active_element/version'
require_relative 'active_element/active_record_text_search_authorization'
require_relative 'active_element/colorized_string'
require_relative 'active_element/active_menu_link'
require_relative 'active_element/permissions_check'
require_relative 'active_element/controller_action'
require_relative 'active_element/rails_component'
require_relative 'active_element/route'
require_relative 'active_element/routes'
require_relative 'active_element/component'
require_relative 'active_element/components'
require_relative 'active_element/engine'

# ActiveElement API Admin UI template and menu system.
module ActiveElement
  class Error < StandardError; end
  class UnprotectedRouteError < Error; end
  class UnknownAttributeError < Error; end

  class << self
    attr_writer :application_name, :navbar_items

    def application_title
      @application_name || RailsComponent.new(Rails).application_name.titleize
    end

    def navbar_items(user)
      @navbar_items || inferred_navbar_items(user)
    end

    def active_path_class(user:, current_navbar_item:, current_path:, controller_path:, action_name:)
      if ActiveMenuLink.new(
        rails_component: RailsComponent.new(Rails),
        navbar_items: navbar_items(user),
        current_path: current_path,
        current_navbar_item: current_navbar_item,
        controller_path: controller_path,
        action_name: action_name
      ).active?
        'active'
      end
    end

    def json_pretty_print(json)
      Components::Util.json_pretty_print(json)
    end

    def with_silenced_logging(&block)
      return block.call unless silence_logging?

      ActiveSupport::Notifications.unsubscribe 'render_template.action_view'
      ActiveSupport::Notifications.unsubscribe 'render_partial.action_view'

      block.call
    end

    def silence_logging?
      return true unless Rails.env.development? || Rails.env.test?
      return true unless ENV.key?('ACTIVE_ELEMENT_DEBUG')

      false
    end

    def eager_load_controllers
      Pathname.new(__dir__)
              .join('../app/controllers/active_element')
              .glob('**/*_controller.rb')
              .each { |path| require path }
      Rails.root.join('app/controllers/admin/').glob('**/*_controller.rb').each { |path| require path }
    end

    private

    def inferred_navbar_items(user)
      eager_load_controllers
      user_routes(user).available.select(&:primary?).map do |route|
        { path: route.path, title: route.title, spec: route.spec }
      end
    end

    def user_routes(user)
      ActiveElement::Routes.new(
        permissions: user.permissions,
        rails_component: ActiveElement::RailsComponent.new(Rails)
      )
    end
  end
end
