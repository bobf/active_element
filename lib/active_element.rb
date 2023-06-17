# frozen_string_literal: true

require 'rouge'
require 'kaminari'
require 'sassc'
require 'bootstrap'
require 'active_record'
require 'paintbrush'

require_relative 'active_element/version'
require_relative 'active_element/active_menu_link'
require_relative 'active_element/permissions_check'
require_relative 'active_element/permissions_report'
require_relative 'active_element/controller_interface'
require_relative 'active_element/controller_action'
require_relative 'active_element/default_controller'
require_relative 'active_element/pre_render_processors'
require_relative 'active_element/rails_component'
require_relative 'active_element/route'
require_relative 'active_element/routes'
require_relative 'active_element/component'
require_relative 'active_element/components'
require_relative 'active_element/json_field_schema'
require_relative 'active_element/engine'

# ActiveElement API Admin UI template and menu system.
module ActiveElement
  class Error < StandardError; end
  class UnprotectedRouteError < Error; end
  class UnknownAttributeError < Error; end

  @eager_loaded = {}

  class << self
    attr_writer :application_name, :navbar_items
    attr_accessor :navbar_items

    include Paintbrush

    def application_title
      @application_name || RailsComponent.new(Rails).application_name.titleize
    end

    def warning(message)
      warn "#{log_tag} #{paintbrush { yellow(message) }}"
    end

    def log_tag
      paintbrush { cyan "[#{blue 'ActiveElement'}]" }
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

    def eager_load_models
      eager_load(:models)
    end

    def eager_load_controllers
      eager_load(:controllers)
    end

    def eager_load(resource)
      return if @eager_loaded[resource]

      suffix = resource == :controllers ? '_controller' : nil
      Rails.root.join("app/#{resource}").glob("**/*#{suffix}.rb").each { |path| require path }
      @eager_loaded[resource] = true
    end

    def element_id
      "active-element-#{SecureRandom.uuid}"
    end
  end
end
