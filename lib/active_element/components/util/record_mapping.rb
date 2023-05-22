# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Maps ActiveRecord record columns and fields to values.
      module RecordMapping
        DATABASE_TYPES = %i[
          string json jsonb integer decimal float datetime time date boolean binary geometry
        ].freeze

        def initialize(component:, record:, field:, options: {})
          @component = component
          @record = record
          @field = field
          @options = options
        end

        def value
          return mapped_value_from_record if association? || column.present?

          value_from_record
        end

        def type
          column&.type
        end

        private

        attr_reader :component, :record, :field, :options

        def column
          return nil unless record.is_a?(ActiveRecord::Base)

          @column ||= record.class.columns.find { |model_column| model_column.name.to_s == field.to_s }
        end

        def association?
          return false unless record.is_a?(ActiveRecord::Base)

          record.association(field).present?
        rescue ActiveRecord::AssociationNotFoundError
          false
        end

        def value_from_record
          record.public_send(field) if record.respond_to?(field)
        end

        def mapped_value_from_record
          return mapped_association_from_record if value_from_record.class.is_a?(ActiveModel::Naming)
          return nil if value_from_record.nil?
          return value_from_record unless DATABASE_TYPES.include?(column.type) || value_from_record.blank?

          send("#{column.type}_value")
        end

        def mapped_association_from_record
          AssociationMapping.new(
            component: component,
            field: field,
            record: record,
            associated_record: value_from_record,
            options: options
          ).link_tag
        end

        # Override these methods as required in a class that includes this module:

        def numeric_value
          value_from_record
        end
        alias integer_value numeric_value
        alias decimal_value numeric_value
        alias float_value numeric_value

        def json_value
          value_from_record
        end
        alias jsonb_value json_value

        def string_value
          value_from_record
        end
        alias text_value string_value

        def datetime_value
          value_from_record
        end

        def time_value
          value_from_record
        end

        def date_value
          value_from_record
        end

        def boolean_value
          value_from_record
        end
        alias binary_value boolean_value

        def geometry_value
          value_from_record
        end
      end
    end
  end
end
