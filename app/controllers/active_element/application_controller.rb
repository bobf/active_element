# frozen_string_literal: true

module ActiveElement
  # Base controller for all ActiveElement API admin front ends, provides standard layout, menu,
  # authentication as Superuser, and standardised HTML widgets.
  class ApplicationController < ActionController::Base
    include ActionView::Helpers::TagHelper

    layout 'active_element'

    before_action -> { authenticate_user! }
    before_action -> { ActiveElement::ControllerAction.new(self).process_action }

    helper_method :active_element_component
    helper_method :render_active_element_hook

    def self.permit_user(permissions, **kwargs)
      active_element_permissions << [permissions, kwargs]

      nil
    end

    def active_element_component
      @active_element_component ||= ActiveElement::Component.new(self)
    end

    def render_active_element_hook(hook)
      render_to_string partial: "/active_element/#{hook}"
    rescue ActionView::MissingTemplate
      nil
    end

    def missing_template_store
      @missing_template_store ||= {}
    end

    def self.active_element_permissions
      @active_element_permissions ||= []
    end
  end
end
