# frozen_string_literal: true

module ActiveElement
  module Components
    # Provides a description of a page, intended to be used underneath the `page_title` component.
    class PageDescription
      def initialize(controller, content:)
        @controller = controller
        @content = content
      end

      def template
        'active_element/components/page_description'
      end

      def locals
        {
          component: self,
          content: content
        }
      end

      private

      attr_reader :controller, :content
    end
  end
end
