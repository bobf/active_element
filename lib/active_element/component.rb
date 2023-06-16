# frozen_string_literal: true

module ActiveElement
  # Exposed by `component` view helper, used as general entrypoint for component creation.
  class Component
    def initialize(controller)
      @controller = controller
    end

    def page_title(title, **kwargs)
      controller.content_tag(:h2, title, **kwargs)
    end

    def page_subtitle(subtitle, **kwargs)
      controller.content_tag(:h3, subtitle, **kwargs)
    end

    def page_section_title(section_title, **kwargs)
      kwargs[:class] ||= 'mt-3'
      controller.content_tag(:h4, section_title, **kwargs)
    end

    def page_description(content)
      render Components::PageDescription.new(controller, content: content)
    end

    def show_button(record = nil, flag_or_options = true, **kwargs) # rubocop:disable Style/OptionalBooleanParameter
      render Components::Button.new(controller, record, flag_or_options, type: :show, **kwargs)
    end

    def new_button(record = nil, flag_or_options = true, **kwargs) # rubocop:disable Style/OptionalBooleanParameter
      render Components::Button.new(controller, record, flag_or_options, type: :new, **kwargs)
    end

    def edit_button(record = nil, flag_or_options = true, **kwargs) # rubocop:disable Style/OptionalBooleanParameter
      render Components::Button.new(controller, record, flag_or_options, type: :edit, **kwargs)
    end

    def destroy_button(record = nil, flag_or_options = true, **kwargs) # rubocop:disable Style/OptionalBooleanParameter
      confirm = kwargs.delete(:confirm) { true }

      render Components::Button.new(
        controller, record, flag_or_options, type: :destroy, confirm: confirm, **kwargs
      )
    end

    def button(title = nil, url = nil, type: 'primary', float: nil, **kwargs, &block)
      render Components::Button.new(
        controller, nil, { path: url, title: title }, type: type, float: float, **kwargs, &block
      )
    end

    def json(key, object)
      render Components::Json.new(controller, object: object, key: key)
    end

    def tabs(class: nil, &block)
      class_name = binding.local_variable_get(:class) || 'tabs'
      render Components::Tabs.new(controller, class_name: class_name, &block)
    end

    def table(**kwargs)
      class_name = kwargs.delete(:class) { default_class(kwargs[:collection], kwargs[:item], kwargs[:model_name]) }

      return render item_table(controller, class_name: class_name, **kwargs) if kwargs.key?(:item)

      if kwargs.key?(:collection)
        return render collection_table(controller, class_name: class_name, params: params, **kwargs)
      end

      raise ArgumentError, 'Must provide one of `item` or `collection`.'
    end

    def form(fields: nil, submit: nil, item: nil, **kwargs)
      render Components::Form.new(controller, fields: fields, submit: submit, item: item, **kwargs)
    end

    private

    attr_reader :controller

    def item_table(controller, **kwargs)
      Components::ItemTable.new(controller, **kwargs)
    end

    def collection_table(controller, **kwargs)
      Components::CollectionTable.new(controller, **kwargs)
    end

    def render(component)
      ActiveElement.with_silenced_logging do
        controller.render_to_string component.template, locals: component.locals, layout: nil
      end
    end

    def default_class(collection, item, model_name)
      return collection.model.name.underscore if collection.respond_to?(:model)
      return class_from_collection(collection, model_name) if collection.present?

      class_from_item(item, model_name)
    end

    def class_from_collection(collection, model_name)
      return model_name.pluralize if model_name.present?
      return nil if collection.nil?

      Components::Util::I18n.class_name(class_name_from_item(collection.first), plural: true)
    end

    def class_from_item(item, model_name)
      return model_name.singularize if model_name.present?
      return nil if item.nil?

      Components::Util::I18n.class_name(class_name_from_item(item))
    end

    def params
      controller.params
    end

    def class_name_from_item(item)
      Components::Util.sti_record_name(item) || Components::Util.record_name(item)
    end
  end
end
