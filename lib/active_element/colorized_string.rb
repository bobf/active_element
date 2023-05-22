# frozen_string_literal: true

module ActiveElement
  # Wraps strings in terminal escape codes to provide colourisation in (e.g.) logging output.
  class ColorizedString
    COLOR_CODES = {
      cyan: '36',
      red: '31',
      green: '32',
      blue: '34',
      purple: '35',
      yellow: '33',
      light_gray: '37',
      light_blue: '1;34',
      white: '1;37'
    }.freeze

    def initialize(string, color:)
      @string = string
      @color = color
    end

    def value
      return string unless Rails.env.development? || Rails.env.test?

      "\e[#{COLOR_CODES.fetch(color)}m#{string}\e[0m"
    end

    private

    attr_reader :string, :color
  end
end
