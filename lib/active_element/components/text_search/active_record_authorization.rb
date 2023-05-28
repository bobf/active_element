# frozen_string_literal: true

ActiveRecord::Base.class_eval do
  class << self
    def authorize_active_element_text_search(with:, providing:)
      ActiveElement::Components::TextSearch.register_authorized_text_search(
        model: self,
        with: with,
        providing: providing
      )
    end
  end
end
