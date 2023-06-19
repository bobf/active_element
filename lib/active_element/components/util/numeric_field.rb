# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Provides options for a `<input type="number" />` element based on database column properties.
      class NumericField
        def initialize(field:, column:)
          @field = field
          @column = column
        end

        def options
          {
            step: step,
            min: min,
            max: max
          }.compact
        end

        private

        attr_reader :field, :column

        def step
          return 'any' if column.blank?
          return '1' if column.type == :integer
          return 'any' if column.try(:scale).blank?

          "0.#{'1'.rjust(column.scale, '0')}"
        end

        def min
          return min_decimal if column.try(:precision).present?
          return min_integer if column.try(:limit).present?

          nil
        end

        def max
          return max_decimal if column.try(:precision).present?
          return max_integer if column.try(:limit).present?

          nil
        end

        # XXX: This is the theoretical maximum value for a column with a given precision but,
        # since the maximum database value is constrained by total significant figures (i.e.
        # before and after the decimal point), an input can still be provided that would cause an
        # error, so the default controller rescues `ActiveRecord::RangeError` to deal with this.
        def max_decimal
          '9' * column.precision
        end

        def min_decimal
          "-#{'9' * column.precision}"
        end

        # `limit` represents available bytes for storing a signed integer e.g.
        # 2**(8 * 8) / 2 - 1 == 9223372036854775807
        # which matches PostgreSQL's `bigint` max value:
        # https://www.postgresql.org/docs/current/datatype-numeric.html
        def max_integer
          ((2**(column.limit * 8)) / 2) - 1
        end

        def min_integer
          -2**(column.limit * 8) / 2
        end
      end
    end
  end
end
