# frozen_string_literal: true

module ActiveElement
  module Components
    # Navigation tabs component.
    class Tabs
      def initialize(controller, class_name:)
        @controller = controller
        @class_name = class_name
        @tabs = []
        yield self
      end

      def to_s
        ''
      end

      def tab(title:, path:, &block)
        Tab.new(controller, title: title, path: path, &block).tap { |tab| @tabs << tab }
      end

      def template
        'active_element/components/tabs'
      end

      def locals
        { tabs: tabs, class_name: class_name }
      end

      private

      attr_reader :tabs, :controller, :class_name
    end
  end
end
