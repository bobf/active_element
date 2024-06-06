# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Normalizes Form `fields` parameter from various supported input formats.
      class FormFieldMapping # rubocop:disable Metrics/ClassLength
        include SecretFields
        include PhoneFields
        include EmailFields

        def initialize(record:, fields:, controller:, i18n:, search: false)
          @controller = controller
          @record = record || default_record
          @fields = fields
          @i18n = i18n
          @search = search
        end

        def fields_with_types_and_options
          compiled_fields = fields.map do |field|
            next field_with_default_type_and_default_options(field) unless field.is_a?(Array)
            next field_with_provided_type_and_provided_options(field) if normalized_field?(field)
            next field_with_default_type_and_provided_options(field) if field_name_with_options?(field)
            next field_with_type(field) if field_name_with_type?(field)

            raise_unrecognized_field_format(field)
          end

          fields_with_default_label(compiled_fields)
        end

        private

        attr_reader :fields, :i18n, :record, :controller, :search

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
          return inline_configured_field(field) if inline_configuration?(field)
          return [field, type_from_file(field).to_sym, options_from_file(field)] if file_configuration?(field)
          return relation_field(field) if relation?(field) && record.present?

          [field, default_type_from_model(field), default_options(field)]
        end

        def inline_configuration?(field)
          inline_configured_field(field).present?
        end

        def inline_configured_field(field)
          field_options = FieldOptions.from_state(
            field, controller.active_element.state, record, controller
          )
          return nil if field_options.blank?

          [field, field_options.type, field_options.options.reverse_merge({ value: field_options.value })]
        end

        def field_with_provided_type_and_provided_options(field)
          return relation_select_field(field.first) if relation?(field.first) && field[1] == :select

          field
        end

        def field_with_type(field)
          [field.first, field.last, default_options(field.first)]
        end

        def association_mapping(field)
          AssociationMapping.new(
            controller: controller,
            field: field,
            record: record,
            associated_record: record.public_send(field)
          )
        end

        def file_configuration?(field)
          # XXX: json_field schema is loaded separately so we ignore file configuration here.
          # This does prevent specifying an alternative field type in a config file but can still
          # be defined inline if e.g. a user wants a text_area instead of a json_field:
          #
          #   active_element.component.form fields: [:foo, :bar, [:some_json_field, :text_area]]
          #
          file_configuration_path(field).present? && default_type_from_model(field) != :json_field
        end

        def type_from_file(field)
          YAML.safe_load(file_configuration_path(field).read, symbolize_names: true)
              .fetch(:type, default_type_from_model(field))
        end

        def options_from_file(field)
          YAML.safe_load(file_configuration_path(field).read, symbolize_names: true).fetch(:options, {})
        end

        def file_configuration_path(field)
          file_configuration_paths(field).compact.find(&:file?)
        end

        def file_configuration_paths(field)
          [
            record_field_configuration_path(field),
            sti_record_field_configuration_paths(field),
            controller_field_configuration_path(field),
            controller_field_configuration_path(field, scope: false)
          ].flatten
        end

        def record_field_configuration_path(field)
          record_name = Util.record_name(record)
          return nil if record_name.blank?

          Rails.root.join('config/forms', record_name, "#{field}.yml")
        end

        def sti_record_field_configuration_paths(field)
          sti_record_names = Util.sti_record_names(record)
          return nil if sti_record_names.blank?

          sti_record_names.map { |name| Rails.root.join('config/forms', name, "#{field}.yml") }
        end

        def controller_field_configuration_path(field, scope: true)
          return nil if controller.blank?

          controller_segment = (scope ? controller.controller_path : controller.controller_name).singularize
          Rails.root.join('config/forms', controller_segment, "#{field}.yml")
        end

        def default_type_from_model(field)
          return default_field_type(field) if record.blank?
          return default_field_type(field) if column(field).blank?

          default_type_from_column_type(field, column(field).type)
        end

        def column(field)
          model&.columns&.find { |model_column| model_column.name.to_s == field.to_s }
        end

        def model
          record&.class || controller.controller_name.classify.safe_constantize
        end

        def relation?(field)
          relation(field).present?
        end

        def relation(field)
          model&.reflect_on_association(field)
        end

        def relation_field(field)
          return relation_text_search_field(field) if association_mapping(field).associated_model.count > 1000

          relation_select_field(field)
        end

        def relation_select_field(field)
          association = association_mapping(field)
          columns = [association.display_field, association.associated_model.primary_key].compact
          [association.relation_key, :select,
           { multiple: association_mapping(field).multiple_association?,
             options: association.associated_model.pluck(*columns) }]
        end

        def relation_text_search_field(field)
          [field, :text_search_field,
           TextSearch.text_search_options(
             model: relation(field).klass,
             with: searchable_fields(field),
             providing: relation(field).klass.primary_key
           ).merge({ display_value: association_mapping(field).display_value, label: i18n.label(field) })]
        end

        def searchable_fields(field)
          fields = Util.relation_controller(model, controller, field)&.active_element&.state&.searchable_fields || []
          # FIXME: Use database column type to only include strings/numbers.
          searchable = fields.reject { |searchable_field| searchable_field.to_s.end_with?('_at') }
          searchable.presence || [:id, :name].reject { |column| model.columns.map(&:name).include?(column) }
        end

        def relation_primary_key(field)
          relation(field).options.fetch(:primary_key) { relation_model.primary_key }
        end

        def default_type_from_column_type(field, column_type) # rubocop:disable Metrics/MethodLength
          {
            string: default_field_type(field),
            boolean: :check_box,
            json: :json_field,
            jsonb: :json_field,
            geometry: :text_area,
            text: :text_area,
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
                                  label: i18n.label(field, record: record),
                                  description: i18n.description(field, record: record),
                                  placeholder: i18n.placeholder(field, record: record)
                                })
        end

        def default_field_type(field)
          return default_search_field_type(field) if search?
          return :password_field if secret_field?(field)
          return :email_field if email_field?(field)
          return :telephone_field if phone_field?(field)

          :text_field
        end

        def search?
          search
        end

        def default_search_field_type(field)
          return :datetime_range_field if column(field)&.type == :datetime

          :text_field
        end

        def default_options(field)
          {
            required: required?(field)
          }.merge(field_options(field))
        end

        def default_record
          controller&.controller_name&.classify&.safe_constantize&.new
        end

        def required?(field)
          return false if search
          return false if record.blank?
          return false unless record.class.respond_to?(:validators)

          record.class.validators.find do |validator|
            validator.kind == :presence && validator.attributes.include?(field.to_sym)
          end
        end

        def field_options(field)
          return NumericField.new(field: field, column: column(field)).options if numeric?(field)

          {}
        end

        def numeric?(field)
          %i[float decimal integer].include?(column(field)&.type)
        end
      end
    end
  end
end
