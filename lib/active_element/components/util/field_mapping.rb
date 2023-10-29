# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Utility class for converting field names to labels, CSS classes, and data mappers.
      class FieldMapping # rubocop:disable Metrics/ClassLength
        include Translations

        def initialize(component, fields, class_name)
          @component = component
          @class_name = class_name
          @fields = fields
        end

        def mapped_fields
          fields.map do |field|
            [
              field,
              class_mapper(field),
              field_to_label(field),
              decorated_value_mapper(field),
              options(field)
            ]
          end
        end

        delegate :model, to: :component

        private

        attr_reader :component, :fields, :class_name

        def options(field)
          { description: i18n.description(field) }
        end

        def decorated_value_mapper(field)
          proc do |item|
            Decorator.new(
              component: component,
              item: item,
              field: field,
              value: value_mapper(field).call(item)
            ).decorated_value
          end
        end

        def field_to_label(field)
          return 'ID' if field == :id # Move to i18n if this gets more complex.
          return i18n.label(field.first) if field.is_a?(Array)

          i18n.label(field)
        end

        def value_mapper(field)
          case field
          when String, Symbol
            default_value_mapper(field)
          when Array
            field.last.fetch(:mapper) { default_value_mapper(*field) }
          end
        end

        def class_mapper(field)
          proc do |item|
            next default_record_classes(field, item).compact.join(' ') if item.class.is_a?(ActiveModel::Naming)

            field_class(field)
          end
        end

        def default_value_mapper(field, options = nil)
          proc do |item|
            next default_record_value(field, item, options) if item.class.is_a?(ActiveModel::Naming)
            next item.public_send(field) if item.class.is_a?(ActiveModel::Naming) && item.respond_to?(field)
            next default_record_value(field, item, options) if hash_field?(item, field)

            nil
          end
        end

        def hash_field?(item, field)
          item.respond_to?(:[]) && item.respond_to?(:key?) && item.key?(field)
        end

        def default_record_value(field, record, options)
          Util::DisplayValueMapping.new(
            component: component,
            field: field,
            record: record,
            options: options
          ).value
        end

        def default_record_classes(field, record)
          if field.is_a?(Array)
            return [
              inferred_class(field.first, record, field.last),
              field_class(field, field.last),
              field.last[:class]
            ]
          end

          [inferred_class(field, record), field_class(field)]
        end

        def inferred_class(field, record, options = nil)
          {
            integer: 'font-monospace', decimal: 'font-monospace', float: 'font-monospace',
            datetime: 'font-monospace', date: 'font-monospace', time: 'font-monospace'
          }.fetch(
            Util::DisplayValueMapping.new(
              component: component, field: field, record: record, options: options
            ).type,
            nil
          )
        end

        def field_to_name(field)
          return field.to_s if field.is_a?(Symbol) || field.is_a?(String)
          return Util::I18n.class_name(field.first) if field.is_a?(Array)

          nil
        end

        def field_class(field, options = {})
          field_name = field_to_name(field)
          base = class_name.blank? ? field_name : "#{class_name}-#{field_name}"
          [base, format_classes(field_name, options.fetch(:format, nil))].flatten.compact.join(' ')
        end

        def format_classes(field_name, format_from_options)
          format_from_translation = i18n.format(field_name)
          [format_class(format_from_translation), format_class(format_from_options)].compact
        end

        def format_class(format)
          { bold: 'fw-bold', monospace: 'font-monospace' }.fetch(format&.to_sym, nil)
        end
      end
    end
  end
end
