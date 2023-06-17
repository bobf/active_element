# frozen_string_literal: true

module ActiveElement
  module Components
    # A table component for rendering a collection of data.
    class CollectionTable
      include LinkHelpers
      include SecretFields
      include Translations

      DEFAULT_PAGE_SIZE = 50

      attr_reader :controller, :model_name

      # rubocop:disable Metrics/MethodLength
      def initialize(controller, class_name:, collection:, fields:, params:, model_name: nil, style: nil,
                     show: false, new: false, edit: false, destroy: false, paginate: true, group: nil,
                     group_title: false, row_class: nil, **_kwargs)
        @controller = controller
        @class_name = class_name
        @model_name = model_name
        @fields = fields
        @collection = with_includes(collection) || []
        @style = style
        @params = params
        @show = show
        @new = new
        @edit = edit
        @destroy = destroy
        @paginate = paginate
        @group = group
        @group_title = group_title
        @row_class = row_class
        verify_paginate_and_group
      end
      # rubocop:enable Metrics/MethodLength

      def template
        'active_element/components/table/collection'
      end

      def locals # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        {
          component: self,
          class_name: class_name,
          collection: group ? collection : paginated_collection,
          fields: Util::FieldMapping.new(self, fields, class_name).mapped_fields,
          style: style,
          new: new,
          show: show,
          edit: edit,
          destroy: destroy,
          group: group,
          group_title: group_title,
          display_pagination: display_pagination?,
          page_sizes: [5, 10, 25, 50, 75, 100, 200],
          page_size: page_size,
          i18n: i18n,
          row_class_mapper: row_class_mapper
        }
      end

      def model
        return collection.model if collection.is_a?(ActiveRecord::Relation)

        collection&.first.class.is_a?(ActiveModel::Naming) ? collection.first.class : nil
      end

      def grouped_collection
        collection.group_by do |item|
          item.class.is_a?(ActiveModel::Naming) ? item.public_send(group) : item.fetch(group)
        end
      end

      private

      attr_reader :class_name, :collection, :fields, :style, :row_class,
                  :new, :show, :edit, :destroy,
                  :paginate, :params, :group, :group_title

      def paginated_collection
        return collection unless paginate && collection.respond_to?(:page)
        return collection.page(page_number).per(page_size) if supports_pagination_but_not_yet_paginated?

        @paginated_collection ||= collection.page(page_number).per(page_size)
      end

      def supports_pagination_but_not_yet_paginated?
        collection.respond_to?(:page) && !collection.respond_to?(:current_per_page)
      end

      def page_number
        params[:page].presence || 1
      end

      def page_size
        params[:page_size].presence || DEFAULT_PAGE_SIZE
      end

      def display_pagination?
        return false if group.present?
        return false unless paginate && paginated_collection.respond_to?(:total_count)

        paginated_collection.total_count > (params[:page_size].presence&.to_i || DEFAULT_PAGE_SIZE)
      end

      def verify_paginate_and_group
        return unless paginate == false && group.present?

        raise ArgumentError, 'Cannot specify both `paginate: false` and a `group` argument.'
      end

      def row_class_mapper
        row_class.is_a?(Proc) ? row_class : proc { row_class }
      end

      def with_includes(collection)
        return collection unless collection.respond_to?(:includes_values)
        return collection if collection.includes_values.present? || collection.select_values.present?

        collection.includes(fields.select { |field| collection.model.reflect_on_association(field).present? })
      end
    end
  end
end
