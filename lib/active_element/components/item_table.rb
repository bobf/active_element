# frozen_string_literal: true

module ActiveElement
  module Components
    # A table component for rendering the fields of a single object horizontally.
    class ItemTable
      include LinkHelpers
      include SecretFields

      attr_reader :controller, :model_name

      def initialize(controller, item:, fields:, class_name: nil, model_name: nil,
                     edit: false, new: false, destroy: false, style: nil, row_class: nil, title: nil, **_kwargs)
        @controller = controller
        @class_name = class_name
        @model_name = model_name
        @item = item
        @fields = fields
        @destroy = destroy
        @edit = edit
        @new = new
        @style = style
        @row_class = row_class
        @title = title
      end

      def template
        'active_element/components/table/item'
      end

      def locals # rubocop:disable Metrics/MethodLength
        {
          component: self,
          class_name: class_name,
          item: item,
          fields: Util::FieldMapping.new(self, fields, class_name).mapped_fields,
          destroy: destroy,
          edit: edit,
          new: new,
          style: style,
          row_class_mapper: row_class_mapper,
          title: title
        }
      end

      def model
        item.class.is_a?(ActiveModel::Naming) ? item.class : nil
      end

      private

      attr_reader :class_name, :item, :fields, :edit, :new, :destroy, :style, :row_class, :title

      def row_class_mapper
        row_class.is_a?(Proc) ? row_class : proc { row_class }
      end
    end
  end
end
