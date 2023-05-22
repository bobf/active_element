# frozen_string_literal: true

module ActiveElement
  module Components
    # Outputs a `<script>` tag and sets globally-available JSON data, available as `ActiveElement.jsonData.<key>`.
    # Note key is camelized, so `foo_bar_baz` becomes `fooBarBaz`.
    class Json
      def initialize(controller, object:, key:)
        @controller = controller
        @object = object
        @key = key
      end

      def template
        'active_element/components/json'
      end

      def locals
        {
          controller: controller,
          object: object,
          key: ActiveElement::Components::Util.json_name(key)
        }
      end

      private

      attr_reader :controller, :object, :key
    end
  end
end
