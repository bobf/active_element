# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Infers a default display value from any given object using multiple strategies.
      class DefaultDisplayValue
        DEFAULT_FIELDS = %i[display_name email name username].freeze

        def initialize(object:)
          @object = object
        end

        def value
          DEFAULT_FIELDS.each do |field|
            return object.public_send(field) if active_record_value?(field)
            return object[field] if hash_key(field) if hash_value?(field)
          end
        end

        private

        attr_reader :object

        def associated_model
          object.model
        end

        def active_record_value?(field)
          return false unless object.is_a?(ActiveRecord::Base)
          return false unless object.respond_to?(field)
          return false unless object.public_send(field).present?

          true
        end

        def hash_value?(field)
          return false unless object.respond_to?(:[])
          return false unless object[field].present? || object[field.to_s].present?

          true
        end

        def hash_key(field)
          return field if object[field].present?
          return field.to_s if object[field.to_s].present?
        end
      end
    end
  end
end
