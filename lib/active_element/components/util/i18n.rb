# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Translates various parameters using `I18n` library, allows users to specify labels,
      # descriptions, placeholders, etc. for various components in locales files.
      class I18n
        def self.class_name(val, plural: false)
          base = val&.to_s&.underscore&.tr('_', '-')&.tr('/', '-')
          plural ? base&.pluralize : base
        end

        def initialize(component)
          @component = component
        end

        def label(field)
          return titleize(field) unless model?

          key = "admin.models.#{model_key}.fields.#{field}.label"
          ::I18n.t(key, default: titleize(field))
        end

        def description(field)
          return nil unless model?

          key = "admin.models.#{model_key}.fields.#{field}.description"
          ::I18n.t(key, default: nil)
        end

        def placeholder(field)
          return nil unless model?

          key = "admin.models.#{model_key}.fields.#{field}.placeholder"
          ::I18n.t(key, default: nil)
        end

        def format(field)
          return nil unless model?

          key = "admin.models.#{model_key}.fields.#{field}.format"
          ::I18n.t(key, default: nil)
        end

        private

        attr_reader :component

        def model_key
          @model_key ||= component.model.name.underscore.pluralize
        end

        def model?
          return false if component.model.nil?

          component.model.is_a?(ActiveModel::Naming)
        end

        def titleize(field)
          field.to_s.titleize(keep_id_suffix: true).gsub(/ Id$/, ' ID')
        end
      end
    end
  end
end
