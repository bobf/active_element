# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Normalizes Form `fields` parameter from various supported input formats.
      class FormFieldMapping
        include SecretFields

        def initialize(record, fields, i18n)
          @record = record
          @fields = fields
          @i18n = i18n
        end

        def fields_with_types_and_options
          compiled_fields = fields.map do |field|
            next field_with_default_type_and_default_options(field) unless field.is_a?(Array)
            next field if normalized_field?(field)
            next field_with_default_type_and_provided_options(field) if field_name_with_options?(field)
            next field_with_type(field) if field_name_with_type?(field)

            raise_unrecognized_field_format(field)
          end

          fields_with_default_label(compiled_fields)
        end

        private

        attr_reader :fields, :i18n, :record

        def normalized_field?(field)
          (field.size == 3) && field.last.is_a?(Hash)
        end

        def field_name_with_options?(field)
          field.size == 2 && field.last.is_a?(Hash)
        end

        def field_name_with_type?(field)
          field.size == 2
        end

        def field_with_default_type_and_default_options(field)
          [field, default_type_from_model(field), {}]
        end

        def field_with_type(field)
          [field.first, field.last, {}]
        end

        def default_type_from_model(field)
          return default_field_type(field) if record.blank?

          column = record.class.columns.find { |model_column| model_column.name.to_s == field.to_s }
          return default_field_type(field) if column.blank?

          default_type_from_column_type(field, column.type)
        end

        def default_type_from_column_type(field, column_type)
          {
            string: default_field_type(field),
            boolean: :check_box,
            json: :json_field,
            jsonb: :json_field,
            geometry: :text_area
          }.fetch(column_type.to_sym, default_field_type(field))
        end

        def field_with_default_type_and_provided_options(field)
          [field.first, default_field_type(field), field.last]
        end

        def fields_with_default_label(fields)
          fields.map do |field, type, options|
            [field, type, options_with_inferred_translations(field, options)]
          end
        end

        def raise_unrecognized_field_format(field)
          raise ArgumentError, "Unexpected field format: #{field}, expected one of: " \
                               ':field_name, [:field_name, :text_field], ' \
                               "or [:field_name, :text_field, { label: 'Field Name', ... }"
        end

        def options_with_inferred_translations(field, options)
          options.reverse_merge({
                                  label: i18n.label(field),
                                  description: i18n.description(field),
                                  placeholder: i18n.placeholder(field)
                                })
        end

        def default_field_type(field)
          return :password_field if secret_field?(field)

          :text_field
        end
      end
    end
  end
end
