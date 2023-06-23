# frozen_string_literal: true

require_relative 'util/i18n'
require_relative 'util/record_path'
require_relative 'util/record_mapping'
require_relative 'util/field_mapping'
require_relative 'util/form_field_mapping'
require_relative 'util/form_value_mapping'
require_relative 'util/display_value_mapping'
require_relative 'util/association_mapping'
require_relative 'util/decorator'
require_relative 'util/numeric_field'

module ActiveElement
  module Components
    # Utility classes for components (data mapping from models, etc.)
    module Util
      def self.json_name(name)
        name.to_s.camelize(:lower)
      end

      def self.record_name(record)
        record&.try(:model_name)&.try(&:singular) || default_record_name(record)
      end

      # TODO: Remove and use .sti_record_names everywhere instead.
      def self.sti_record_name(record)
        return default_record_name(record) unless record.class.respond_to?(:inheritance_column)

        record&.class&.superclass&.model_name&.singular if record&.try(record.class.inheritance_column).present?
      end

      def self.sti_record_names(record)
        record.class.ancestors.select do |ancestor|
          next false if ancestor == record.class
          next false unless ancestor.try(:inheritance_column).present?
          next false unless ancestor < ActiveRecord::Base
          next false unless !ancestor.abstract_class?

          true
        end.map(&:model_name).map(&:singular)
      end

      def self.default_record_name(record)
        (record.is_a?(Class) ? record.name : record.class.name).demodulize.underscore
      end

      def self.relation_controller(model, controller, relation)
        namespace = controller.controller_path.rpartition('/').first.presence
        base = "#{model.reflect_on_association(relation).klass.name.pluralize}Controller"
        return base.safe_constantize if namespace.nil?

        "#{namespace.classify}::#{base}".safe_constantize || base.safe_constantize
      end

      def self.json_schema(model:, field:)
        YAML.safe_load(
          Rails.root.join("config/forms/#{model.name.underscore}/#{field}.yml").read,
          symbolize_names: true
        )
      end

      def self.json_pretty_print(json)
        formatter = Rouge::Formatters::HTML.new
        lexer = Rouge::Lexers::JSON.new
        content = JSON.pretty_generate(json.is_a?(String) ? JSON.parse(json) : json)
        formatted = formatter.format(lexer.lex(content)).gsub('  ', '&nbsp;&nbsp;').gsub("\n", '<br/>')
        # rubocop:disable Rails/OutputSafety
        # TODO: Move to a template.
        "<div class='json-highlight' style='font-family: monospace;'>#{formatted}</div>".html_safe
        # rubocop:enable Rails/OutputSafety
      end
    end
  end
end
