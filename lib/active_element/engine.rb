# frozen_string_literal: true

module ActiveElement
  # Provides initial setup and gem integration for host Rails application.
  class Engine < ::Rails::Engine
    initializer 'active_element.precompile' do |app|
      next unless app.config.respond_to?(:assets)

      app.config.assets.precompile += %w[
        active_element/manifest.js
      ]
    end

    initializer 'active_element.routes' do |app|
      app.routes.append do
        mount Engine => '/'
      end
    end

    initializer 'active_element.silence_action_view_notifications', after: 'finisher_hook' do
      next unless ActiveElement.silence_logging?

      warn '*** Rails ActionView logging events are disabled by default. Set ACTIVE_ELEMENT_DEBUG=1 to enable.'
    end
  end
end
