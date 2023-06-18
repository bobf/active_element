# frozen_string_literal: true

module ActiveElement
  # Provides params for ActiveRecord models when using the default boilerplate controller
  # actions. Navigates input parameters and maps them to appropriate relations as needed.
  class DefaultRecordParams
    def initialize(controller:, model:)
      @controller = controller
      @model = model
    end

    def params
      with_transformed_relations(
        controller.params.require(controller.controller_name.singularize)
                  .permit(controller.active_element.state.fetch(:editable_fields, []))
      )
    end

    private

    attr_reader :controller, :model

    def with_transformed_relations(params)
      params.to_h.to_h do |key, value|
        next [key, value] unless relation?(key)

        relation_param(key, value)
      end
    end

    def relation_param(key, value)
      case relation(key).macro
      when :belongs_to
        belongs_to_param(key, value)
      when :has_one
        has_one_param(key, value)
      when :has_many
        has_many_param(key, value)
      end
    end

    def belongs_to_param(key, value)
      [relation(key).foreign_key, value]
    end

    def has_one_param(key, value) # rubocop:disable Naming/PredicateName
      [relation(key).name, relation(key).klass.find_by(relation(key).klass.primary_key => value)]
    end

    def has_many_param(key, _value) # rubocop:disable Naming/PredicateName
      [relation(key).name, relation(key).klass.where(relation(key).klass.primary_key => relation(key).value)]
    end

    def relation?(attribute)
      relation(attribute.to_sym).present?
    end

    def relation(attribute)
      model.reflect_on_association(attribute.to_sym)
    end
  end
end
