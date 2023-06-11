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

        def path
          record_path || sti_record_path
        rescue NoMethodError
          raise Error,
                "Unable to map #{record.inspect} to a Rails route. Tried:\n" \
                "#{[default_record_path, sti_record_path].compact.join("\n")}"
        end

        private

        attr_reader :record, :controller, :type

        def namespace_prefix
          # XXX: We guess the namespace from the current controller's module name. This will work
          # most of the time but will break if the current record's controller exists in a different
          # namespace to the current controller, e.g. `BackEndAdmin::UsersController` and
          # `FrontEndAdmin::ThemesController` - if `FrontEndAdmin::ThemesController` renders a
          # collection of `User` objects, the "show" path will be wrong:
          # `front_end_admin_user_path`. Maybe descend through the full controller class tree to
          # find a best match ?
          namespace = controller.class.name.deconstantize.underscore
          return nil if namespace.blank?

          "#{namespace}_"
        end

        def record_path
          return nil if record.nil?

          controller.helpers.public_send(default_record_path, *path_arguments)
        rescue NoMethodError
          raise NoMethodError if sti_record_name.nil?

          controller.helpers.public_send(sti_record_path, *path_arguments)
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
          "#{record_path_prefix}#{namespace_prefix}#{record_name}_path"
        end

        def sti_record_path
          return nil if sti_record_name.nil?

          "#{record_path_prefix}#{namespace_prefix}#{sti_record_name}_path"
        end

        def record_name
          return Util.record_name(record) unless pluralize?

          Util.record_name(record)&.pluralize
        end

        def sti_record_name
          return Util.sti_record_name(record) unless pluralize?

          Util.sti_record_name(record)
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
