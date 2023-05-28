# frozen_string_literal: true

module ActiveElement
  module Components
    module TextSearch
      # Encapsulates generation of database adapter-specific sanitized SQL queries for performing
      # full text searches. Identifies columns and adapters where `LIKE` or `ILIKE` can be
      # applied and generates a whereclause according to the provided parameters.
      #
      # Receives an ActiveRecord model class, a query (a string used to match results), attribute
      # columns to match against, and a value column to return in the results.
      #
      # Inspects ActiveRecord metadata to match field names to column objects.
      class Sql
        def initialize(model:, query:, value:, attributes:)
          @model = model
          @query = query
          @value = value
          @attributes = attributes
        end

        def value_column
          return nil if value.blank?

          @value_column ||= model&.columns&.find { |column| column.name == value }
        end

        def search_columns
          return [] if attributes.blank?

          @search_columns ||= attributes.map { |attribute| column_for(attribute) }.compact
        end

        def whereclause
          clauses = search_columns.map { |column| "#{column.name} #{operator(column)} ?" }
          [clauses.join(' OR '), search_columns.map { |column| search_param(column) }].flatten
        end

        private

        attr_reader :model, :query, :value, :attributes

        def column_for(attribute)
          matched_column = model&.columns&.find { |column| column.name == attribute }
          return nil if matched_column.blank?

          compatible_column?(matched_column) ? matched_column : nil
        end

        def operator(column)
          case column.type
          when :string
            %w[Mysql2 SQLite].include?(model.connection.adapter_name) ? 'LIKE' : 'ILIKE'
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
      end
    end
  end
end
