# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Utility class for mapping an association to a linked URL display value, (e.g. for
      # displaying associations in a table, form, etc.).
      class AssociationMapping
        def initialize(controller:, field:, record:, associated_record:, options: {})
          @controller = controller
          @field = field
          @record = record
          @associated_record = associated_record
          @options = options || {}
        end

        def link_tag
          verify_display_attribute
          return display_value if associated_record_path.blank?

          controller.helpers.link_to(display_value, associated_record_path)
        end

        def foreign_key_value
          record.public_send(foreign_key)
        end

        def foreign_key
          record.class.reflect_on_association(field).foreign_key
        end

        def display_value(with_foreign_key: false)
          return nil if display_field.nil?

          value = associated_record.public_send(display_field)
          return value unless with_foreign_key

          "#{value} (#{foreign_key}: #{foreign_key_value})"
        end

        private

        attr_reader :controller, :field, :record, :associated_record, :options

        def associated_record_path
          return nil unless controller.helpers.respond_to?(path_helper)

          controller.helpers.public_send(path_helper, associated_record)
        end

        def verify_display_attribute
          return if display_field.present?

          raise ArgumentError,
                "Must provide { attribute: :example_attribute } for `#{field}` or define " \
                "`#{associated_record.class.name}.default_display_attribute`"
        end

        def display_field
          @display_field ||= options.fetch(:attribute) do
            next associated_record.class.default_display_attribute if defined_display_attribute?
            next default_display_attribute if default_display_attribute.present?

            associated_record&.class&.primary_key
          end
        end

        def defined_display_attribute?
          associated_record.class.respond_to?(:default_display_attribute)
        end

        def namespace
          controller.class.name.deconstantize.underscore
        end

        def resource_name
          record.public_send(field).model_name.singular
        end

        def default_display_attribute
          %i[name email display_name username].find do |display_field|
            associated_record.respond_to?(display_field) && associated_record.method(display_field).arity.zero?
          end
        end

        def path_helper
          return "#{resource_name}_path" if namespace.blank?

          "#{namespace}_#{resource_name}_path"
        end
      end
    end
  end
end
