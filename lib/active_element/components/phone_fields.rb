# frozen_string_literal: true

module ActiveElement
  module Components
    # Provides a convenience method for detecting a field should be classified as a phone number.
    module PhoneFields
      PHONE_FIELDS = %w[phone telephone tel mobile].freeze

      def phone_field?(field)
        PHONE_FIELDS.any? { |phone_field| field.to_s.downcase.split('_').include?(phone_field) }
      end
    end
  end
end
