# frozen_string_literal: true

module ActiveElement
  module Components
    # A form component for rendering a standard form with various inputs in a uniform manner,
    # includes validation errors.
    class Form # rubocop:disable Metrics/ClassLength
      include Translations

      attr_reader :controller

      # rubocop:disable Metrics/MethodLength
      def initialize(controller, fields:, submit:, item:, title: nil, destroy: false,
                     modal: false, columns: 1, **kwargs)
        @controller = controller
        @fields = fields
        @title = title
        @submit = submit
        @destroy = destroy
        @item = item
        @modal = modal
        @kwargs = kwargs
        @columns = columns
        @action = kwargs.delete(:action) { default_action }
        @method = kwargs.delete(:method) { default_method }.to_s.downcase.to_sym
      end
      # rubocop:enable Metrics/MethodLength

      def template
        'active_element/components/form'
      end

      def locals # rubocop:disable Metrics/MethodLength
        {
          component: self,
          fields: Util::FormFieldMapping.new(record, fields, i18n).fields_with_types_and_options,
          record: record,
          submit_label: submit_label,
          submit_position: submit_position,
          class_name: class_name,
          method: method,
          action: action,
          kwargs: kwargs,
          destroy: destroy,
          modal: modal,
          columns: columns,
          title: title,
          id: form_id
        }
      end

      def class_name
        [default_class_name, kwargs.fetch(:class, nil)].compact.join(' ')
      end

      def options_for_select(field, field_options)
        return [['', '']] + base_options_for_select(field, field_options) unless field_options[:blank] == false

        base_options_for_select(field, field_options)
      end

      def valid?(field = nil)
        return true if record.blank? || !record.changed?

        record.valid?

        return record&.errors.blank? if field.nil?

        valid_field?(field)
      end

      def name_for(form, schema_field, type:)
        base = "#{form.object_name}[#{schema_field.fetch(:name)}]"
        type == :array ? "#{base}[]" : base
      end

      def schema_for(field, options)
        options.key?(:schema) ? options.fetch(:schema) : schema_from_yaml(field)
      end

      def schema_from_yaml(field)
        YAML.safe_load(
          Rails.root.join("config/forms/#{record.class.name.underscore}/#{field}.yml").read,
          symbolize_names: true
        )
      end

      def display_value_for_select(field, options)
        options_for_select(field, options).find do |_display_value, value|
          value == value_for(field)
        end&.first
      end

      def value_for(field, default = nil)
        return form_value_mapping_value(field) if record.class.is_a?(ActiveModel::Naming)
        return default_record_value(field, default) if record.present? && record.respond_to?(field)
        return item[field].presence || default if item.present?

        default
      end

      def form_value_mapping_value(field)
        Util::FormValueMapping.new(component: self, record: record, field: field).value
      end

      def default_record_value(field, default)
        record&.public_send(field).presence || default
      end

      def options_for_json_array_field(options)
        options.map { |option| option.is_a?(Array) ? option : [option, option] }
      end

      def value_for_json_array_field(field, schema_field, element_index = nil)
        array = value_for(field, {}).fetch(schema_field[:name], [])
        return array if element_index.nil?

        array.fetch(element_index, nil)
      end

      def record
        return nil if kwargs.fetch(:model, nil).blank?

        kwargs[:model].is_a?(Array) ? kwargs[:model].last : kwargs[:model]
      end

      def model
        record&.class
      end

      private

      attr_reader :fields, :submit, :title, :kwargs, :item, :method, :action,
                  :destroy, :modal, :columns

      def valid_field?(field)
        return true if record.respond_to?("#{field}_changed?") && !record.public_send("#{field}_changed?")

        record&.errors.blank? || record.errors.full_messages_for(field).blank?
      end

      def submit_position
        return submit[:position] if submit.is_a?(Hash) && submit[:position].present?

        :bottom
      end

      def submit_label
        return submit[:label] if submit.is_a?(Hash) && submit[:label].present?
        return submit if submit.is_a?(String)
        return submit_label_from_model if record.present? && submit_label_from_model.present?

        'Submit'
      end

      def submit_label_from_model
        return "Create #{humanized_model_name}" if record.present? && method == :post
        return "Save Changes" if record.present? && %i[patch put].include?(method)

        nil
      end

      def humanized_model_name
        record.class.name.titleize
      end

      def base_options_for_select(field, field_options)
        return normalized_options(field_options.fetch(:options)) if field_options.key?(:options)
        return default_options_for_select(field, field_options) if record.class.is_a?(ActiveModel::Naming)

        raise ArgumentError, "Must provide select options `[:#{field}, { options: [...] }]` or a record instance."
      end

      def normalized_options(options)
        options.map { |option| option.is_a?(Array) ? option : [option, option] }
      end

      def default_class_name
        return nil if record.blank?

        Util::I18n.class_name(record.class.name)
      end

      def default_options_for_select(field, field_options)
        options = record.class.distinct.order(field).pluck(field)
        [options.map { |option| autoformat(option, field_options) }, options].transpose
      end

      def form_id
        kwargs.fetch(:id) { ActiveElement.element_id }
      end

      def autoformat(val, field_options)
        return val unless field_options[:autoformat] || !field_options.key?(:autoformat)

        val.titleize
      end

      def default_method
        case controller.action_name
        when 'edit', 'update'
          'PATCH'
        when 'index'
          'GET'
        else
          'POST'
        end
      end

      def default_action
        return controller.request.path unless record.is_a?(ActiveModel::Naming)

        Util::RecordPath.new(record: record, controller: controller).path
      end
    end
  end
end
