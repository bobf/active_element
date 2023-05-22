# frozen_string_literal: true

ActiveRecord::Base.class_eval do
  class << self
    attr_reader :authorized_active_element_text_search_fields

    def authorize_active_element_text_search_for(field, exposes:)
      @authorized_active_element_text_search_fields ||= []
      @authorized_active_element_text_search_fields << [field, exposes]
    end
  end
end
