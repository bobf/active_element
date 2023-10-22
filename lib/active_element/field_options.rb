module ActiveElement
  class FieldOptions
    attr_accessor :type, :options
    attr_reader :field

    def initialize(field)
      @field = field
      @options = {}
    end
  end
end
