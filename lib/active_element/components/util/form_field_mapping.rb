# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Normalizes Form `fields` parameter from various supported input formats.
      class FormFieldMapping
        include SecretFields
        include PhoneFields
        include EmailFields

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
          return [field, type_from_file(field).to_sym, options_from_file(field)] if file_configuration?(field)

          [field, default_type_from_model(field), {}]
        end

        def field_with_type(field)
          [field.first, field.last, {}]
        end

        def file_configuration?(field)
          # XXX: json_field schema is loaded separately so we ignore file configuration here.
          # This does prevent specifying an alternative field type in a config file but can still
          # be defined inline if e.g. a user wants a text_area instead of a json_field:
          #
          #   active_element.component.form fields: [:foo, :bar, [:some_json_field, :text_area]]
          #
          file_configuration_path(field).file? && default_type_from_model(field) != :json_field
        end

        def type_from_file(field)
          YAML.safe_load(file_configuration_path(field).read, symbolize_names: true)
              .fetch(:type, default_type_from_model(field))
        end

        def options_from_file(field)
          YAML.safe_load(file_configuration_path(field).read, symbolize_names: true).fetch(:options, {})
        end

        def file_configuration_path(field)
          record_field_configuration_path(field) || sti_field_configuration_path(field)
        end

        def record_field_configuration_path(field)
          record_name = Util.record_name(record)
          return nil if record_name.blank?

          Rails.root.join('config/forms').join(record_name, "#{field}.yml")
        end

        def sti_record_field_configuration_path(field)
          sti_record_name = Util.sti_record_name(record)
          return nil if sti_record_name.blank?

          Rails.root.join('config/forms').join(sti_record_name, "#{field}.yml")
        end

        def default_type_from_model(field)
          return default_field_type(field) if record.blank?

          column = record.class.columns.find { |model_column| model_column.name.to_s == field.to_s }
          return default_field_type(field) if column.blank?

          default_type_from_column_type(field, column.type)
        end

        def default_type_from_column_type(field, column_type) # rubocop:disable Metrics/MethodLength
          {
            string: default_field_type(field),
            boolean: :check_box,
            json: :json_field,
            jsonb: :json_field,
            geometry: :text_area,
            datetime: :datetime_field,
            date: :date_field,
            time: :time_field,
            integer: :number_field,
            decimal: :number_field,
            float: :number_field
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
          return :email_field if email_field?(field)
          return :phone_field if phone_field?(field)

          :text_field
        end
      end
    end
  end
end
