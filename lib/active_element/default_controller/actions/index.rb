# frozen_string_literal: true

module ActiveElement
  module DefaultController
    module Actions
      # Default index action, rendered if no `#index` controller method defined.
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
          return unordered_collection.order(state.list_order) if state.list_order.present?
          return unordered_collection.order(**order_params) if order_params.present?

          unordered_collection
        end

        def order_params
          return nil if controller.params[:_order].blank?

          @order_params ||= { controller.params[:_order].first => controller.params[:_order].last }
        end
      end
    end
  end
end
