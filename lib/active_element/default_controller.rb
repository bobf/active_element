# frozen_string_literal: true

module ActiveElement
  # Encapsulation of all logic performed for default controller actions when no action is defined
  # by the current controller.
  class DefaultController
    def initialize(controller:)
      @controller = controller
    end

    def index
      controller.render 'active_element/default_views/index',
                        locals: {
                          collection: collection,
                          search_filters: default_text_search.search_filters
                        }
    end

    def show
      controller.render 'active_element/default_views/show', locals: { record: record }
    end

    def new
      controller.render 'active_element/default_views/new', locals: { record: model.new, namespace: namespace }
    end

    def create # rubocop:disable Metrics/AbcSize
      new_record = model.new(default_record_params.params)
      # Ensure associations are applied:
      if new_record.save && new_record.reload.update(default_record_params.params)
        controller.flash.notice = "#{new_record.model_name.to_s.titleize} created successfully."
        controller.redirect_to record_path(new_record, :show).path
      else
        controller.flash.now.alert = "Failed to create #{model.name.to_s.titleize}."
        controller.render 'active_element/default_views/new', locals: { record: new_record, namespace: namespace }
      end
    end

    def edit
      controller.render 'active_element/default_views/edit', locals: { record: record, namespace: namespace }
    end

    def update # rubocop:disable Metrics/AbcSize
      if record.update(default_record_params.params)
        controller.flash.notice = "#{record.model_name.to_s.titleize} updated successfully."
        controller.redirect_to record_path(record, :show).path
      else
        controller.flash.now.alert = "Failed to update #{model.name.to_s.titleize}."
        controller.render 'active_element/default_views/edit', locals: { record: record, namespace: namespace }
      end
    end

    def destroy
      record.destroy
      controller.flash.notice = "Deleted #{record.model_name.to_s.titleize}."
      controller.redirect_to record_path(model, :index).path
    end

    private

    attr_reader :controller

    def default_record_params
      @default_record_params ||= ActiveElement::DefaultRecordParams.new(controller: controller, model: model)
    end

    def default_text_search
      @default_text_search ||= ActiveElement::DefaultTextSearch.new(controller: controller, model: model)
    end

    def record_path(record, type = nil)
      ActiveElement::Components::Util::RecordPath.new(record: record, controller: controller, type: type)
    end

    def namespace
      controller.controller_path.rpartition('/').first.presence&.to_sym
    end

    def model
      controller.controller_name.classify.constantize
    end

    def record
      @record ||= model.find(controller.params[:id])
    end

    def collection
      return model.all unless default_text_search.text_search?

      model.left_outer_joins(default_text_search.search_relations).where(*default_text_search.text_search)
    end
  end
end
