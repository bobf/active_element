# frozen_string_literal: true

module ActiveElement
  module DefaultController
    module Actions
      class Index
        def initialize(controller:, model:, state:)
          @controller = controller
          @model = model
          @state = state
        end

        def render
          controller.render 'active_element/default_views/index',
                            locals: {
                              collection: ordered(collection),
                              search_filters: search.search_filters
                            }
        end

        private

        attr_reader :controller, :model, :state

        def search
          @search ||= DefaultController::Search.new(controller: controller, model: model)
        end

        def collection
          return model.all unless search.text_search?

          model.left_outer_joins(search.search_relations).where(*search.text_search)
        end

        def ordered(unordered_collection)
          return unordered_collection if state.list_order.blank?

          unordered_collection.order(state.list_order)
        end
      end
    end
  end
end
