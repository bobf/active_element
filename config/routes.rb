# frozen_string_literal: true

ActiveElement::Engine.routes.draw do
  ActiveElement.eager_load_controllers

  ActiveElement::ApplicationController.descendants.map do |descendant|
    post "#{descendant.controller_path}/_active_element_text_search",
         controller: descendant.controller_path,
         action: '_active_element_text_search'

    # Permissions for text search are managed by ActiveElement::Components::TextSearch::Authorization
    descendant.active_element.permit_action :_active_element_text_search, always: true
  end
end
