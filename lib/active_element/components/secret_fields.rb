# frozen_string_literal: true

module ActiveElement
  module Components
    # Provides a convenience method for detecting a field should be classified as a secret, used
    # for censoring values or selecting the default form field type as `password_field`, etc.
    module SecretFields
      SECRET_FIELDS = %w[secret password].freeze

      def secret_field?(field)
        SECRET_FIELDS.any? { |secret_field| field.to_s.downcase.include?(secret_field) }
      end
    end
  end
end
