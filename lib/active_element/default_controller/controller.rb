# frozen_string_literal: true

module ActiveElement
  module DefaultController
    # Encapsulation of all logic performed for default controller actions when no action is defined
    # by the current controller.
    class Controller
      def initialize(controller:)
        @controller = controller
      end

      def index
        return render_forbidden(:listable) unless configured?(:listable)

        Actions::Index.new(controller: controller, model: model, state: state).render
      end

      def show
        return render_forbidden(:viewable) unless configured?(:viewable)

        controller.render 'active_element/default_views/show', locals: { record: record }
      end

      def new
        return render_forbidden(:editable) unless configured?(:editable)

        controller.render 'active_element/default_views/new', locals: { record: model.new, namespace: namespace }
      end

      def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        return render_forbidden(:editable) unless configured?(:editable)

        new_record = model.new(default_record_params.params)
        # XXX: Ensure associations are applied - there must be a better way.
        if new_record.save && new_record.reload.update(default_record_params.params)
          controller.flash.notice = "#{new_record.model_name.to_s.titleize} created successfully."
          controller.redirect_to record_path(new_record, :show).path
        else
          controller.flash.now.alert = "Failed to create #{model.name.to_s.titleize}."
          controller.render 'active_element/default_views/new', locals: { record: new_record, namespace: namespace }
        end
      rescue ActiveRecord::RangeError => e
        render_range_error(error: e, action: :new)
      end

      def edit
        return render_forbidden(:editable) unless configured?(:editable)

        controller.render 'active_element/default_views/edit', locals: { record: record, namespace: namespace }
      end

      def update # rubocop:disable Metrics/AbcSize
        return render_forbidden(:editable) unless configured?(:editable)

        if record.update(default_record_params.params)
          controller.flash.notice = "#{record.model_name.to_s.titleize} updated successfully."
          controller.redirect_to record_path(record, :show).path
        else
          controller.flash.now.alert = "Failed to update #{model.name.to_s.titleize}."
          controller.render 'active_element/default_views/edit', locals: { record: record, namespace: namespace }
        end
      rescue ActiveRecord::RangeError => e
        render_range_error(error: e, action: :edit)
      end

      def destroy
        return render_forbidden(:deletable) unless configured?(:deletable)

        record.destroy
        controller.flash.notice = "Deleted #{record.model_name.to_s.titleize}."
        controller.redirect_to record_path(model, :index).path
      end

      private

      attr_reader :controller

      def render_forbidden(type)
        controller.render 'active_element/default_views/forbidden', locals: { type: type }
      end

      def configured?(type)
        return state.deletable? if type == :deletable

        state.public_send("#{type}_fields").present?
      end

      def state
        @state ||= controller.active_element.state
      end

      def default_record_params
        @default_record_params ||= DefaultController::Params.new(controller: controller, model: model)
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

      def render_range_error(error:, action:)
        controller.flash.now.alert = formatted_error(error)
        controller.render "active_element/default_views/#{action}", locals: { record: record, namespace: namespace }
      end

      def formatted_error(error)
        return error.cause.message.split("\n").join(', ') if error.try(:cause)&.try(:message).present?
        return error.message if error.try(:message).present?

        I18n.t('active_element.unexpected_error')
      end
    end
  end
end
