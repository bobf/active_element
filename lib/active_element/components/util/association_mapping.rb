# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Utility class for mapping an association to a linked URL (e.g. for displaying associations in a table).
      class AssociationMapping
        def initialize(component:, field:, record:, associated_record:, options:)
          @component = component
          @field = field
          @record = record
          @associated_record = associated_record
          @options = options || {}
        end

        def link_tag
          verify_display_attribute
          return display_value if associated_record_path.blank?

          component.controller.helpers.link_to(display_value, associated_record_path)
        end

        private

        attr_reader :component, :field, :record, :associated_record, :options

        def associated_record_path
          return nil unless component.controller.helpers.respond_to?(path_helper)

          component.controller.helpers.public_send(path_helper, associated_record)
        end

        def verify_display_attribute
          return if display_field.present?

          raise ArgumentError,
                "Must provide { attribute: :example_attribute } for `#{field}` or define " \
                "`#{associated_record.class.name}.default_display_attribute`"
        end

        def display_value
          associated_record.public_send(display_field)
        end

        def display_field
          @display_field ||= options.fetch(:attribute) do
            next associated_record.class.default_display_attribute if defined_display_attribute?
            next default_display_attribute if default_display_attribute.present?

            associated_record.class.primary_key
          end
        end

        def defined_display_attribute?
          associated_record.class.respond_to?(:default_display_attribute)
        end

        def namespace
          component.controller.class.name.deconstantize.underscore
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
