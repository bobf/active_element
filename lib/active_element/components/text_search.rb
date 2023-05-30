# frozen_string_literal: true

require_relative 'text_search/active_record_authorization'
require_relative 'text_search/sql'
require_relative 'text_search/component'
require_relative 'text_search/authorization'

module ActiveElement
  module Components
    # Provides back end for live text search components.
    module TextSearch
      @authorized_text_searches = []

      class << self
        attr_reader :authorized_text_searches

        def register_authorized_text_search(model:, with:, providing:)
          authorized_text_searches << [model, with, providing]
        end
      end
    end
  end
end