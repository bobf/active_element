# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Translates various parameters using `I18n` library, allows users to specify labels,
      # descriptions, placeholders, etc. for various components in locales files.
      class I18n
        def self.class_name(val, plural: false)
          base = val&.to_s&.underscore&.tr('/', '_')
          plural ? base&.pluralize : base
        end

        def initialize(component)
          @component = component
        end

        def label(field, record: nil)
          return titleize(field) unless model?(record)

          key = "admin.models.#{model_key(record)}.fields.#{field}.label"
          ::I18n.t(key, default: titleize(field))
        end

        def description(field, record: nil)
          return nil unless model?(record)

          key = "admin.models.#{model_key(record)}.fields.#{field}.description"
          ::I18n.t(key, default: nil)
        end

        def placeholder(field, record: nil)
          return nil unless model?(record)

          key = "admin.models.#{model_key(record)}.fields.#{field}.placeholder"
          ::I18n.t(key, default: nil)
        end

        def format(field, record: nil)
          return nil unless model?(record)

          key = "admin.models.#{model_key(record)}.fields.#{field}.format"
          ::I18n.t(key, default: nil)
        end

        private

        attr_reader :component

        def model_key(record = nil)
          @model_key ||= (record&.class || component.model).name.underscore.pluralize
        end

        def model?(record = nil)
          return false if record.nil? && component.model.nil?

          (record&.class || component.model).is_a?(ActiveModel::Naming)
        end

        def titleize(field)
          field.to_s.titleize(keep_id_suffix: true).gsub(/ Id$/, ' ID')
        end
      end
    end
  end
end
