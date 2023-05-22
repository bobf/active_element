# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Decorates a field by rendering a user-provided partial found in
      # app/views/decorators/<model-name-plural>/_<field-name>.html.erb
      class Decorator
        def initialize(component:, item:, field:, value:)
          @component = component
          @item = item
          @field = field
          @value = value
        end

        def decorated_value
          return default_decorated_value unless decorate?

          render
        end

        private

        attr_reader :component, :item, :field, :value

        def render(sti: false)
          component.controller.render_to_string(partial: decorator_path(sti: sti), locals: locals)
        rescue ActionView::MissingTemplate
          if sti
            component.controller.missing_template_store[decorator_path] = true
            default_decorated_value
          else
            render(sti: true)
          end
        end

        def locals
          {
            record: item,
            field: field,
            default: value,
            value: value, # Provide both default and value, default might change in future.
            context: component.class.name.demodulize.underscore
          }
        end

        def decorate?
          return false unless item.class.is_a?(ActiveModel::Naming) || component.model_name.present?

          !missing_template?
        end

        def missing_template?
          component.controller.missing_template_store[decorator_path].present?
        end

        def decorator_path(sti: false)
          Rails.root.join(
            'app/views/decorators',
            model_path_name(sti: sti).pluralize,
            field.to_s
          ).relative_path_from(Rails.root.join('app/views')).to_s
        end

        def model_path_name(sti:)
          return component.model_name if component.model_name.present?
          return record_name(sti: sti) if record_name(sti: sti).present?
          return item_record_name if item_record_name.present?

          item.class.name
        end

        def record_name(sti:)
          return Util.sti_record_name(item) if sti

          Util.record_name(item).presence
        end

        def item_record_name
          item.try(:model_name)&.singular
        end

        def render_with_default_decorator(template)
          component.controller.render_to_string(
            partial: "active_element/decorators/#{template}",
            locals: { value: value }
          )
        end

        def default_decorated_value # rubocop:disable Metrics/MethodLength
          case value
          when true, false
            render_with_default_decorator('boolean')
          when DateTime
            render_with_default_decorator('datetime')
          when Date
            render_with_default_decorator('date')
          when Time
            render_with_default_decorator('time')
          else
            value
          end
        end
      end
    end
  end
end
