# frozen_string_literal: true

module ActiveElement
  module Components
    # Provides `#i18n` method as standard entrypoint to translation point, specifies required
    # interface for classes that use this module.
    module Translations
      def i18n
        @i18n ||= Util::I18n.new(self)
      end

      def model
        raise NotImplementedError,
              'Component must implement `#model` and return `nil` or an ActiveRecord model class.'
      end
    end
  end
end
