module ActiveElement
  module DefaultControllerActions
    extend ActiveSupport::Concern

    def index
      render 'active_element/default_views/index', locals: { collection: model.all }
    end

    def show
      render 'active_element/default_views/show', locals: { record: record }
    end

    def new
      render 'active_element/default_views/new', locals: { record: model.new }
    end

    def create
      if model.create(default_record_params)
        flash.notice = "#{record.model_name} created successfully."
        redirect_to record
      else
        flash.alert = "Failed to create #{model.name}."
        render :new
      end
    end

    def edit
      render 'active_element/default_views/edit', locals: { record: record }
    end

    def update
      if record.update(default_record_params)
        flash.notice = "#{record.model_name} updated successfully."
        redirect_to record
      else
        flash.alert = "Failed to update #{model.name}."
        render :edit
      end
    end

    def destroy
      record.destroy
      flash.notice = "Deleted #{record.model_name}."
      redirect_to model
    end

    private

    def model
      controller_name.classify.constantize
    end

    def record
      @record ||= model.find(params[:id])
    end

    def default_record_params
      params.require(record.model_name.singular)
            .permit(active_element.state.fetch(:editable_fields, []))
    end
  end
end
