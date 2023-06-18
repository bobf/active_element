# frozen_string_literal: true

module ActiveElement
  module PreRenderProcessors
    # Selects fields from `__json_fields` param created by `Components::JsonField` and parses
    # each field's JSON data back into request params to allow for transparent JSON data receipt.
    # All params are permitted and converted to a Hash to allow them to be modified before
    # converting back to ActionController::Params to avoid disrupting the Rails request flow.
    class Json
      def initialize(controller:)
        @controller = controller
      end

      def process
        return if json_fields.blank?

        process_json_fields
        delete_meta_params
        rebuild_action_controller_parameters
      end

      private

      attr_reader :controller

      def process_json_fields
        json_fields.zip(json_values).each do |field, value|
          *nested_keys, field_key = field.split('.')
          param = nested_keys.reduce(permitted_params) { |params, key| params[key] }
          schema = schema_for(nested_keys + [field_key])
          param[field_key] = coerced_with_default(value, schema)
        end
      end

      def coerced_with_default(value, schema)
        return coerced_value(JSON.parse(value), schema: schema) unless value == ''

        { 'array' => [], 'object' => {} }.fetch(schema['type'])
      end

      def delete_meta_params
        permitted_params.delete('__json_fields')
        permitted_params.delete('__json_field_schemas')
      end

      def rebuild_action_controller_parameters
        controller.params = ActionController::Parameters.new(permitted_params)
      end

      def json_fields
        controller.params['__json_fields']
      end

      def json_values
        json_fields.map do |json_field|
          json_field.split('.').reduce(controller.params) { |params, field| params[field] }
        end
      end

      def permitted_params
        @permitted_params ||= controller.params.permit!.to_h
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      def coerced_value(val, schema:)
        return val if val.nil?

        case schema['type']
        when 'array'
          val.map { |item| coerced_value(item, schema: schema['shape']) }
        when 'object'
          val.to_h { |key, value| [key, coerced_value(value, schema: schema_field(schema, key))] }
        when 'string', 'boolean', 'time'
          val
        when 'float'
          Float(val)
        when 'integer'
          Integer(val)
        when 'decimal'
          BigDecimal(val)
        when 'datetime'
          DateTime.parse(val)
        when 'date'
          Date.parse(val)
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength

      def schema_for(path)
        JSON.parse(path.reduce(permitted_params['__json_field_schemas']) { |schema, key| schema[key] })
      end

      def schema_field(schema, key)
        schema['shape']['fields'].find { |each_field| each_field['name'] == key }
      end
    end
  end
end
