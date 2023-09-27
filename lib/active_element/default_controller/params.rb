# frozen_string_literal: true

module ActiveElement
  module DefaultController
    # Provides params for ActiveRecord models when using the default boilerplate controller
    # actions. Navigates input parameters and maps them to appropriate relations as needed.
    class Params
      def initialize(controller:, model:)
        @controller = controller
        @model = model
      end

      def params
        with_transformed_relations(
          controller.params.require(controller.controller_name.singularize)
                    .permit(*permitted_fields)
        )
      end

      private

      attr_reader :controller, :model

      def with_transformed_relations(params)
        params.to_h.to_h do |key, value|
          next [key, value] unless relation?(key)

          relation_param(key, value)
        end
      end

      def permitted_fields
        scalar, json = controller.active_element.state.editable_fields.partition do |field|
          scalar?(normalized_field_name(field))
        end
        (scalar + [json_params(json)]).map { |field| normalized_field_name(field) }
      end

      def normalized_field_name(field)
        field.is_a?(Array) ? field.first : field
      end

      def scalar?(field)
        return true if relation?(field)
        return true if %i[json jsonb].exclude?(column(field)&.type)

        false
      end

      def json_params(fields)
        # XXX: We assume all non-scalar fields are JSON fields, i.e. they must have a definition
        # defined as `config/forms/<model>/<field>.yml`. If that file does not exist, allow
        # Errno::ENOENT to raise to let the form submission fail and avoid losing data. This
        # would need to be adjusted if we start allowing non-JSON nested fields in the default
        # controller.
        fields.index_with do |field|
          DefaultController::JsonParams.new(schema: schema_for(field)).params
        end
      end

      def schema_for(field)
        ActiveElement::Components::Util.json_schema(model: model, field: field)
      end

      def relation_param(key, value)
        case relation(key).macro
        when :belongs_to
          belongs_to_param(key, value)
        when :has_one
          has_one_param(key, value)
        when :has_many
          has_many_param(key, value)
        end
      end

      def belongs_to_param(key, value)
        [relation(key).foreign_key, value]
      end

      def has_one_param(key, value) # rubocop:disable Naming/PredicateName
        [relation(key).name, relation(key).klass.find_by(relation(key).klass.primary_key => value)]
      end

      def has_many_param(key, _value) # rubocop:disable Naming/PredicateName
        [relation(key).name, relation(key).klass.where(relation(key).klass.primary_key => relation(key).value)]
      end

      def relation?(attribute)
        relation(attribute.to_sym).present?
      end

      def relation(attribute)
        model.reflect_on_association(attribute.to_sym)
      end

      def column(attribute)
        model.columns.find { |column| column.name.to_s == attribute.to_s }
      end
    end
  end
end
