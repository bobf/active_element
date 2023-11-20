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
          return value_from_config if value_from_config.present?
          return mapped_value_from_record if active_record? || column.present?

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

        def active_record?
          association? || value_from_record.is_a?(ActiveRecord::Base)
        end

        def association?
          return false unless record.is_a?(ActiveRecord::Base)

          !record.association(field).nil?
        rescue ActiveRecord::AssociationNotFoundError
          false
        end

        def value_from_record
          return nil if field.blank?

          @value_from_record ||= if record.respond_to?(field) && record.is_a?(ActiveRecord::Base)
                                   record.public_send(field)
                                 elsif record.respond_to?(:key?) && record.respond_to?(:[]) && record.key?(field)
                                   record[field]
                                 elsif record.respond_to?(field)
                                   record.public_send(field)
                                 end
        end

        def mapped_value_from_record
          return mapped_association_from_record if association?
          return nil if value_from_record.nil?
          return value_from_record unless DATABASE_TYPES.include?(column.type) || value_from_record.blank?

          send("#{column.type}_value")
        end

        def association_mapping
          @association_mapping ||= AssociationMapping.new(
            controller: component.controller,
            field: field,
            record: record,
            associated_record: value_from_record,
            options: options
          )
        end

        def value_from_config
          field_options = FieldOptions.from_state(field, component.controller.active_element.state, record)
          return nil if field_options.blank?
          return nil unless DATABASE_TYPES.include?(field_options.type.to_sym)

          send("#{field_options.type}_value")
        end

        # Override these methods as required in a class that includes this module:

        def mapped_association_from_record
          association_mapping.relation_id
        end

        def numeric_value
          value_from_record
        end

        def integer_value
          numeric_value
        end

        def decimal_value
          numeric_value
        end

        def float_value
          numeric_value
        end

        def json_value
          value_from_record
        end

        def jsonb_value
          json_value
        end

        def string_value
          value_from_record
        end

        def text_value
          string_value
        end

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

        def binary_value
          boolean_value
        end

        def geometry_value
          value_from_record
        end

        def timezone_offset
          component.controller.request.cookies['timezone_offset'].to_i.minutes
        end

        def with_timezone_offset(val)
          return val if val.blank?

          val - timezone_offset
        end
      end
    end
  end
end
