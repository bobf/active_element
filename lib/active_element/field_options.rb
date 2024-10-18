module ActiveElement
  class FieldOptions
    attr_accessor :options, :value, :exact_match
    attr_writer :type
    attr_reader :field

    def self.from_state(field, state, record, controller)
      block = state.field_options[field]
      return nil if block.blank?

      field_options = new(field)
      block.call(field_options, record, controller)
      field_options
    end

    def initialize(field)
      @field = field
      @options = {}
    end

    def type
      @type || :text_field
    end
  end
end
