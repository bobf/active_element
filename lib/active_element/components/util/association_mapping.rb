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
          return associated_record.map { |value| link_to(value) } if multiple_association?
          return link_to(associated_record) if single_association?
        end

        def relation_id # rubocop:disable Metrics/CyclomaticComplexity
          case relation.macro
          when :has_one
            associated_record&.public_send(relation_key)
          when :has_many
            associated_record&.map(&relation_key.to_sym)
          when :belongs_to
            record&.public_send(relation_key)
          end
        end

        def relation_key
          case relation.macro
          when :has_one, :has_many
            relation.klass.primary_key
          when :belongs_to
            relation.foreign_key
          end
        end

        def display_value(value = associated_record)
          return value&.public_send(display_field) if display_field.present?
          return nil if associated_model&.primary_key.blank?

          value.public_send(associated_model.primary_key)
        end

        def display_field
          @display_field ||= options.fetch(:attribute) do
            next associated_model.default_display_attribute if defined_display_attribute?
            next default_display_attribute if default_display_attribute.present?

            associated_model.primary_key
          end
        end

        def total_count
          associated_model&.count
        end

        def options_for_select(scope: nil)
          return [] if associated_model.blank?

          base = scope.nil? ? associated_model : associated_model.public_send(scope)
          base.all.pluck(display_field, associated_model.primary_key).sort.map do |title, value|
            next [title, value] if display_field == associated_model.primary_key

            ["#{title} (#{value})", value]
          end
        end

        def single_association?
          %i[has_one belongs_to].include?(relation.macro)
        end

        def multiple_association?
          relation.macro == :has_many
        end

        private

        attr_reader :controller, :field, :record, :associated_record, :options

        def relation
          @relation ||= record.class.reflect_on_association(field)
        end

        def associated_record_path(path_for)
          return nil unless controller.helpers.respond_to?(path_helper)

          controller.helpers.public_send(path_helper, path_for)
        end

        def verify_display_attribute
          return if display_field.present?

          raise ArgumentError,
                "Must provide { attribute: :example_attribute } for `#{field}` or define " \
                "`#{associated_record.class.name}.default_display_attribute`"
        end

        def defined_display_attribute?
          associated_model.respond_to?(:default_display_attribute)
        end

        def namespace
          controller.class.name.deconstantize.underscore
        end

        def resource_name
          record.public_send(field)&.model_name&.singular
        end

        def default_display_attribute
          %i[name email display_name username].find do |display_field|
            next true if associated_model_callable_method?(display_field.to_sym)
            next true if associated_model.columns.map(&:name).map(&:to_sym).include?(display_field.to_sym)

            false
          end
        end

        def associated_model
          record.association(field).klass
        end

        def associated_model_callable_method?(name)
          return false unless associated_model.public_instance_methods.include?(name)
          return false unless associated_model.public_instance_method(name).arity.zero?

          true
        end

        def path_helper
          return "#{resource_name}_path" if namespace.blank?

          "#{namespace}_#{resource_name}_path"
        end

        def link_to(value)
          return display_value(value) if associated_record_path(value).blank?

          controller.helpers.link_to(display_value(value), associated_record_path(value))
        end
      end
    end
  end
end
