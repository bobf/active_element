# frozen_string_literal: true

ActiveElement::Engine.routes.draw do
  post '/_text_search', controller: 'active_element/text_searches', action: 'create'
end
