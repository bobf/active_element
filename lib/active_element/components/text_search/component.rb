# frozen_string_literal: true

module ActiveElement
  module Components
    module TextSearch
      # Used by auto-complete search field for executing a text search on the provided model and
      # attributes.
      #
      # The user must have a permission configured for each field used in the search:
      #   `can_text_search_<application_name>_<models>_with_<field>`
      #
      # A model must call `authorize_active_element_text_search` to enable text search. e.g.:
      #
      # class MyModel < ApplicationRecord
      #   authorize_active_element_text_search with: [:id, :email],
      #                                        providing: [:id, :first_name, :last_name, :email]
      # end
      #
      # This allows searching using the `name` `email` columns and permits returning each matching
      # record's `id`, `first_name`, `last_name`, and `email` values.
      #
      # This complexity exists to ensure that authenticated users can only retrieve specific
      # database values that are explicitly configured, as well as ensuring that users cannot
      # search arbitrary columns. Requiring this logic in the model is intended to reduce
      # likelihood of DoS vulnerabilities if users are able to search unindexed columns.
      #
      # Note that the `/_active_element_text_search` endpoint added to each controller
      # necessarily receives arbitrary arguments. Configuring a form to only fetch certain values
      # does not restrict potential parameters, so a strict permissions and model configuration
      # system is required to govern access to database queries.
      #
      class Component
        DEFAULT_LIMIT = 50

        def initialize(controller:)
          @controller = controller
          @params = controller.params
        end

        def response
          return unverified_parameters unless verified_parameters?
          return unverified_model unless verified_model?
          return unauthorized unless authorization.authorized?

          { json: { results: results, request_id: controller.params[:request_id] }, status: :created }
        end

        private

        attr_reader :controller, :params

        def verified_parameters?
          %i[model attributes value query].all? { |parameter| params[parameter].present? }
        end

        def unverified_parameters
          { json: { message: 'Must provide parameters: [model, attributes, value, query] for text search.' },
            status: :unprocessable_entity }
        end

        def verified_model?
          [model, sql.search_columns, sql.value_column].all?(&:present?)
        end

        def unverified_model
          { json: { message: authorization.message(colorize: false) }, status: :unprocessable_entity }
        end

        def unauthorized
          { json: { message: authorization.message(colorize: false) }, status: :forbidden }
        end

        def sql
          @sql ||= Sql.new(
            model: model,
            query: params[:query],
            value: params[:value],
            attributes: params[:attributes]
          )
        end

        def results
          @results ||= model.where(*sql.whereclause)
                            .limit(limit)
                            .pluck(sql.value_column.name, *sql.search_columns.map(&:name))
                            .map { |value, *attributes| result(value, attributes) }
                            .uniq
        end

        def result(value, attributes)
          { value: value, attributes: attributes.reject { |attribute| attribute == value } }
        end

        def model
          @model ||= ActiveRecord::Base.descendants.find do |descendant|
            descendant.name == params[:model].camelize(:upper)
          end
        end

        def authorization
          @authorization ||= TextSearch::Authorization.new(
            model: model,
            params: params,
            user: controller.active_element.current_user,
            search_columns: sql.search_columns.compact,
            result_columns: (sql.search_columns + [sql.value_column]).compact
          )
        end

        def query
          params[:query]
        end

        def limit
          DEFAULT_LIMIT
        end
      end
    end
  end
end
