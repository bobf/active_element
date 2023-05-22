# frozen_string_literal: true

module ActiveElement
  # Used by auto-complete search field for executing a text search on the provided model and
  # attributes.
  #
  # The user must have the permission `can_create_<application_name>_active_element_text_searches`.
  #
  # A model must call `authorize_active_element_text_search_for` to enable text search. e.g.:
  #
  # class MyModel < ApplicationRecord
  #   authorize_active_element_text_search_for :name, exposes: [:email]
  # end
  #
  # This will allow searching on the `name` column and permits returning each matching record's
  # `:email` column's value.
  #
  # TODO: Refactor logic into separate classes.
  # rubocop:disable Metrics/ClassLength
  class TextSearchesController < ApplicationController
    DEFAULT_LIMIT = 50

    before_action :verify_parameters
    before_action :verify_model

    def create
      render json: { results: results, request_id: params[:request_id] }
    end

    private

    def verify_parameters
      return if %i[model attributes value query].all? { |parameter| params[parameter].present? }

      render json: { message: 'Must provide parameters: [model, attributes, value, query] for text search.' },
             status: :unprocessable_entity
    end

    def verify_model
      return if [model, search_columns, value_column].all?(&:present?) && authorized?

      render json: { message: verify_fail_message }, status: :unprocessable_entity
    end

    def verify_fail_message
      requested = %i[model attributes value].index_with { |key| params[key] }
                                            .compact_blank
                                            .map { |key, value| "#{key}: #{value}" }
      "Unpermitted or unavailable search for: { #{requested.join(', ')} }"
    end

    def results
      @results ||= model.where(*whereclause)
                        .limit(limit)
                        .pluck(value_column.name, *search_columns.map(&:name))
                        .map { |value, *attributes| result(value, attributes) }
    end

    def result(value, attributes)
      { value: value, attributes: attributes.reject { |attribute| attribute == value } }
    end

    def model
      @model ||= params[:model].camelize(:upper).safe_constantize
    end

    def query
      params[:query]
    end

    def value_column
      return nil if params[:value].blank?

      @value_column ||= model&.columns&.find { |column| column.name == params[:value] }
    end

    def search_columns
      return nil if params[:attributes].blank?

      @search_columns ||= params[:attributes].map { |attribute| column_for(attribute) }.compact
    end

    def column_for(attribute)
      matched_column = model&.columns&.find { |column| column.name == attribute }
      return nil if matched_column.blank?

      compatible_column?(matched_column) ? matched_column : nil
    end

    def authorized?
      model.authorized_active_element_text_search_fields&.any? do |field, exposed|
        exposed = [exposed] unless exposed.is_a?(Array)
        authorized_field?(field, exposed)
      end
    end

    def authorized_field?(field, exposed)
      return false unless search_columns.map { |column| column.name.to_sym }.include?(field.to_sym)
      return false unless exposed&.map(&:to_sym)&.include?(value_column.name.to_sym)

      true
    end

    def whereclause
      clauses = search_columns.map { |column| "#{column.name} #{operator(column)} ?" }
      [clauses.join(' OR '), search_columns.map { |column| search_param(column) }].flatten
    end

    def operator(column)
      case column.type
      when :string
        model.connection.adapter_name == 'SQLite' ? 'LIKE' : 'ILIKE'
      else
        '='
      end
    end

    def compatible_column?(column) # rubocop:disable Metrics/MethodLength
      case column.type
      when :string
        true
      when :integer
        integer?
      when :float
        float?
      when :decimal
        decimal?
      else
        Rails.logger.info("Skipping query `#{query}` for incompatible column: #{column.name}")
        false
      end
    end

    def integer?
      Integer(query)
      true
    rescue ArgumentError
      false
    end

    def float?
      Float(query)
      true
    rescue ArgumentError
      false
    end

    def decimal?
      BigDecimal(query)
      true
    rescue ArgumentError
      false
    end

    def search_param(column)
      case column.type
      when :string
        "#{query}%"
      else
        query
      end
    end

    def limit
      DEFAULT_LIMIT
    end

    def permissions_check
      @permissions_check ||= PermissionsCheck.new(
        required: [],
        actual: current_user.permissions,
        controller_path: controller_path,
        action_name: action_name,
        rails_component: rails_component
      )
    end

    def required_permissions
      application_name = rails_component.application_name
      permission = "can_text_search_#{application_name}_#{params[:model]&.pluralize}"
      [[permission, { only: :create }]]
    end

    def rails_component
      @rails_component ||= RailsComponent.new(Rails)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
