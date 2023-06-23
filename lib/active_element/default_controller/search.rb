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
          next model.arel_table[key].matches("#{value}%") if [:string, :text].include?(column(key).type)

          model.arel_table[key].eq(value)
        end
        conditions[1..].reduce(conditions.first) do |accumulated, condition|
          accumulated.and(condition)
        end
      end

      def search_relations
        search_filters.to_h.keys.map { |key| relation?(key) ? key.to_sym : nil }.compact
      end

      private

      attr_reader :controller, :model

      def column(key)
        model.columns.find { |column| column.name.to_s == key.to_s }
      end

      def searchable_fields
        controller.active_element.state.searchable_fields.map do |field|
          next field unless field.to_s.end_with?('_at')

          { field => %i[from to] }
        end
      end

      def noop
        Arel::Nodes::True.new.eq(Arel::Nodes::True.new)
      end

      def datetime?(key)
        column(key)&.type == :datetime
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
        fields = searchable_relation_fields(key)
        relation_model = relation(key).klass
        fields.select! do |field|
          relation_model.columns.find { |column| column.name.to_s == field.to_s }&.type == :string
        end

        return noop if fields.empty?

        relation_conditions(fields, value, relation_model)
      end

      def relation_conditions(fields, value, relation_model)
        fields[1..].reduce(relation_model.arel_table[fields.first].matches("#{value}%")) do |condition, field|
          condition.or(relation_model.arel_table[field].matches("#{value}%"))
        end
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
