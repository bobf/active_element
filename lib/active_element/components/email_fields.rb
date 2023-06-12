# frozen_string_literal: true

module ActiveElement
  module Components
    # Provides a convenience method for detecting a field should be classified as an email address.
    module EmailFields
      EMAIL_FIELDS = %w[email email_address].freeze

      def email_field?(field)
        EMAIL_FIELDS.any? { |email_field| field.to_s.downcase == email_field }
      end
    end
  end
end
