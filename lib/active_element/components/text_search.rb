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

        def text_search_options(model:, with:, providing:)
          {
            search: { model: model.name.underscore, with: with, providing: providing },
            placeholder: "Search for #{model.name.titleize} by #{humanized_names(with).join(', ')}..."
          }
        end

        private

        def humanized_names(names)
          Array(names).compact.map.map(&:to_s).map(&:humanize)
        end
      end
    end
  end
end
