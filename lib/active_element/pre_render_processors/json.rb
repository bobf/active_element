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
        delete_meta_param
        rebuild_action_controller_parameters
      end

      private

      attr_reader :controller

      def process_json_fields
        json_fields.zip(json_values).each do |field, value|
          *nested_keys, field_key = field.split('.')
          param = nested_keys.reduce(permitted_params) { |params, key| params[key] }
          # If value is an empty string then something went wrong in front end code. Skip
          # reassignment completely to prevent data loss.
          param[field_key] = JSON.parse(value) unless value == ''
        end
      end

      def delete_meta_param
        permitted_params.delete('__json_fields')
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
    end
  end
end
