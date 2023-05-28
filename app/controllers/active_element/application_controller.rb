# frozen_string_literal: true

module ActiveElement
  # Base controller for all ActiveElement API admin front ends, provides standard layout, menu,
  # authentication as Superuser, and standardised HTML widgets.
  class ApplicationController < ActionController::Base
    include ActionView::Helpers::TagHelper

    layout 'active_element'

    def self.active_element
      @active_element ||= ActiveElement::ControllerInterface.new(self)
    end

    def active_element
      @active_element ||= ActiveElement::ControllerInterface.new(self.class, self)
    end

    before_action -> { active_element.authenticator&.call }
    before_action -> { ActiveElement::ControllerAction.new(self).process_action }

    helper_method :active_element
    helper_method :render_active_element_hook

    def render_active_element_hook(hook)
      render_to_string partial: hook
    rescue ActionView::MissingTemplate
      nil
    end

    def _active_element_text_search
      render(**ActiveElement::Components::TextSearch::Component.new(controller: self).response)
    end
  end
end
