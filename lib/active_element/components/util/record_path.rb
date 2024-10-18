# frozen_string_literal: true

module ActiveElement
  module Components
    module Util
      # Generates Rails paths from records, used to generate form actions and links for Rails RESTful routes.
      class RecordPath
        def initialize(record:, controller:, type: nil)
          @record = record
          @controller = controller
          @type = type&.to_sym || controller.action_name&.to_sym
        end

        def path(**kwargs)
          record_path(**kwargs)
        rescue NoMethodError
          ActiveElement.warning("Unable to map #{record.inspect} to a Rails route (#{@controller.class.name}##{@type}). Tried:\n" \
                                "#{all_record_paths.join("\n")}")
          nil
        end

        def link(**kwargs)
          controller.helpers.link_to(DefaultDisplayValue.new(object: record).value, path(**kwargs))
        end

        def model
          all_names.find do |name|
            controller.helpers.public_send(record_path_for(name), *path_arguments)
          rescue NoMethodError
            nil
          end&.classify&.constantize || default_model
        end

        def namespace
          # XXX: We guess the namespace from the current controller's module name. This will work
          # most of the time but will break if the current record's controller exists in a different
          # namespace to the current controller, e.g. `BackEndAdmin::UsersController` and
          # `FrontEndAdmin::ThemesController` - if `FrontEndAdmin::ThemesController` renders a
          # collection of `User` objects, the "show" path will be wrong:
          # `front_end_admin_user_path`. Maybe descend through the full controller class tree to
          # find a best match ?
          controller.class.name.deconstantize.underscore.to_sym
        end

        private

        def default_model
          controller.controller_name.classify&.constantize
        end

        def all_names
          @all_names ||= ([record_name] + sti_record_names).compact
        end

        def all_record_paths
          @all_record_paths ||= all_names.map { |name| record_path_for(name) }
        end

        def namespace_prefix
          return nil if namespace.blank?

          "#{namespace}_"
        end

        attr_reader :record, :controller, :type

        def record_path(**kwargs) # rubocop:disable Metrics/AbcSize
          return nil if record.nil? || default_record_path.nil?

          controller.helpers.public_send(default_record_path, *path_arguments, **kwargs)
        rescue NoMethodError
          raise if sti_record_names.blank?

          sti_record_names.each do |sti_record_name|
            return controller.helpers.public_send(record_path_for(sti_record_name), *path_arguments, **kwargs)
          rescue NoMethodError
            nil
          end

          raise
        end

        def path_arguments
          case type
          when :edit, :update, :show, :destroy
            [record]
          when :new, :index
            []
          end
        end

        def default_record_path
          if record.try(:active_element_controller_name).present?
            record.active_element_controller_name
                  .constantize.controller_path
                  .underscore
                  .singularize.tr('/', '_') + '_path'
          else
            "#{record_path_prefix}#{namespace_prefix}#{record_name}_path"
          end
        rescue NameError
          nil
        end

        def record_path_for(name)
          "#{record_path_prefix}#{namespace_prefix}#{name}_path"
        end

        def record_name
          return Util.record_name(record) unless pluralize?

          Util.record_name(record)&.pluralize
        end

        def sti_record_names
          return Util.sti_record_names(record) unless pluralize?

          Util.sti_record_names(record).map(&:pluralize)
        end

        def record_path_prefix
          case type
          when :edit
            'edit_'
          when :new
            'new_'
          end
        end

        def pluralize?
          case type
          when :index, :create
            true
          else
            false
          end
        end
      end
    end
  end
end
