# frozen_string_literal: true

module ActiveElement
  module DefaultController
    # Full text search and datetime querying for DefaultController, provides full text search
    # filters for all controllers with configured searchable fields. Includes support for querying
    # across relations.
    class Search
      def initialize(controller:, model:)
        @controller = controller
        @model = model
      end

      def search_filters
        @search_filters ||= controller.params.permit(*searchable_fields).transform_values do |value|
          value.try(:compact_blank) || value
        end.compact_blank
      end

      def text_search?
        search_filters.present?
      end

      def text_search
        conditions = search_filters.to_h.map do |key, value|
          next relation_matches(key, value) if relation?(key)
          next datetime_between(key, value) if datetime?(key)
          next join(key, value) if key.to_s.include?('.')
          next model.arel_table[key].matches("#{value}%") if string_like_column?(key)

          model.arel_table[key].eq(value)
        end

        conditions[1..].reduce(conditions.first) do |accumulated, condition|
          accumulated.and(condition)
        end
      end

      def search_relations
        relation_joins = search_filters.to_h.keys.map { |key| relation?(key) ? key.to_sym : nil }.compact
        (relation_joins + shorthand_joins).uniq
      end

      def shorthand_joins
        search_filters.to_h
                      .keys
                      .select { |key| key.to_s.include?('.') }
                      .map { |key| key.partition('.').first.to_sym }
      end

      private

      attr_reader :controller, :model

      def string_like_column?(key)
        exact = controller.active_element.state.field_options&.find do |field, options_proc|
          field_options = FieldOptions.new(key)
          options_proc.call(field_options, nil, controller)
          field_options.exact_match
        end

        return false if exact

        [:string, :text].include?(
          model.columns.find { |column| column.name.to_s == key.to_s }&.type&.to_sym
        )
      end

      def searchable_fields
        fields = controller.active_element.state.searchable_fields.map do |field|
          next field unless field.to_s.end_with?('_at')

          { field => %i[from to] }
        end
        (fields + relation_fields).uniq
      end

      def relation_fields
        controller.active_element.state.searchable_fields.map do |field|
          next nil unless relation?(field)

          relation(field).try(:foreign_key)
        end.compact
      end

      def join(key, value)
        table, _, column = key.to_s.partition('.')
        relation(table).klass.arel_table[column].eq(value)
      end

      def noop
        Arel::Nodes::True.new.eq(Arel::Nodes::True.new)
      end

      def datetime?(key)
        model.columns.find { |column| column.name.to_s == key.to_s }&.type == :datetime
      end

      def datetime_between(key, value)
        return noop if value[:from].blank? && value[:to].blank?

        model.arel_table[key].between(range_begin(value)...range_end(value))
      end

      def range_begin(value)
        value[:from].present? ? Time.zone.parse(value[:from]) + timezone_offset : -Float::INFINITY
      end

      def range_end(value)
        value[:to].present? ? Time.zone.parse(value[:to]) + timezone_offset : Float::INFINITY
      end

      def timezone_offset
        controller.request.cookies['timezone_offset'].to_i.minutes
      end

      def relation_matches(key, value)
        foreign_key = relation(key).try(:foreign_key)
        return noop unless foreign_key.present?

        model.arel_table[foreign_key].eq(value)
      end

      def searchable_relation_fields(key)
        Components::Util.relation_controller(model, controller, key)
                        &.active_element
                        &.state
                        &.fetch(:searchable_fields, []) || []
      end

      def relation?(attribute)
        relation(attribute.to_sym).present?
      end

      def relation(attribute)
        model.reflect_on_association(attribute.to_sym)
      end
    end
  end
end
