# frozen_string_literal: true

module ActiveElement
  class JsonFieldSchema
    def initialize(table:, column:)
      @table = table
      @column = column
    end

    def schema
      data.map { |datum| structure(datum) }
    end

    private

    attr_reader :table, :column, :initial_structure

    def data
      @data ||= ActiveRecord::Base.connection
                                  .execute("select #{column} from #{table}")
                                  .pluck(column)
                                  .map { |datum| JSON.parse(datum) }
    end

    def structure(datum)
      {
        type: schema_type(datum),
        shape: schema_shape(datum)&.compact,
        fields: schema_fields(datum)&.compact
      }
    end

    def schema_type(val)
      case val
      when Hash
        'object'
      when Array
        'array'
      when String
        'string'
      end
    end

    def schema_shape(val)
      return nil unless %w[array object].include?(schema_type(val))
      return val.map { |item| structure(item).compact } if schema_type(val) == 'array'
      return val.map { |key, value| (structure(value)).compact } if schema_type(val) == 'object'

      { type: schema_type(val) }
    end

    def schema_fields(val)
      return nil unless schema_type(val) == 'object'

      val.map { |key, value| { name: key }.merge(structure(value)).compact }
    end
  end
end
