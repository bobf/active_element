# frozen_string_literal: true

module ActiveElement
  module DefaultController
    # Provides permitted parameters for fields generated from a JSON schema file.
    class JsonParams
      def initialize(schema:)
        @base_schema = schema
      end

      def params(schema = base_schema)
        return simple_object_field(schema) if simple_object_field?(schema)
        return simple_array_field(schema) if simple_array_field?(schema)
        return complex_array_field(schema) if complex_array_field?(schema)

        schema[:name]
      end

      private

      attr_reader :fields, :base_schema

      def simple_object_field(schema)
        schema.key?(:name) ? { schema[:name] => {} } : {}
      end

      def simple_array_field(schema)
        schema.key?(:name) ? { schema[:name] => [] } : []
      end

      def simple_object_field?(schema)
        schema[:type] == 'object'
      end

      def simple_array_field?(schema)
        schema[:type] == 'array' && schema.dig(:shape, :type) != 'object'
      end

      def complex_array_field?(schema)
        schema[:type] == 'array' && schema.dig(:shape, :type) == 'object'
      end

      def complex_array_field(schema)
        schema.dig(:shape, :shape, :fields).map { |field| params(field) }
      end
    end
  end
end
