# frozen_string_literal: true

module ActiveElement
  module Components
    # One navigation tab in a Tabs component.
    class Tab
      attr_reader :title, :path, :content

      def initialize(controller, title:, path:, &block)
        @controller = controller
        @title = title
        @path = path
        @content = block_given? ? block.call : ''
      end

      def selected?
        controller.request.fullpath == path
      end

      def identifier
        Util::I18n.class_name(title)
      end

      def to_s
        ''
      end

      def tab(title)
        yield Tab.new(title)
      end

      private

      attr_reader :controller
    end
  end
end
