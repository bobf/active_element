# frozen_string_literal: true

module ActiveElement
  module Components
    module TextSearch
      # Manages authorization for text search, ensures model is configured for text search and
      # that user has correct permissions.
      class Authorization
        include Paintbrush

        class << self
          def permission_for(model:, field:)
            "can_text_search_#{application_name}_#{model.name.underscore.pluralize}_with_#{field}"
          end

          private

          def application_name
            RailsComponent.new(::Rails).application_name
          end
        end

        def initialize(model:, params:, user:, search_columns:, value_column:)
          @model = model
          @params = params
          @user = user
          @search_columns = search_columns
          @value_column = value_column
        end

        def authorized?
          return true if authorized_model? && authorized_user?
          return false.tap { ActiveElement.warning(message) } unless Rails.env.development?

          ActiveElement.warning(development_message)
          true
        end

        def message(colorize: true)
          [
            missing_authorization_message(colorize: colorize),
            missing_permissions_message(colorize: colorize)
          ].compact.join(paintbrush(colorize: colorize) { red '. ' })
        end

        private

        attr_reader :model, :params, :user, :search_columns, :value_column

        def development_message
          paintbrush { green "Bypassed text search authorization in development environment: #{yellow message}" }
        end

        def missing_permissions
          (search_columns + [value_column]).reject { |column| user_permitted?(column) }
                                           .map { |column| permission_for(column.name) }
                                           .uniq
                                           .sort
        end

        def missing_permissions_message(colorize:)
          return nil if missing_permissions.empty?

          paintbrush(colorize: colorize) { red "Missing permissions: #{yellow missing_permissions.join(', ')}" }
        end

        def missing_authorization_message(colorize:)
          return nil if authorized_model?

          paintbrush(colorize: colorize) do
            red "Missing model authorization for #{cyan model_name} with: " \
                "#{green search_fields.join(', ')}, providing: " \
                "#{green result_fields.join(', ')}"
          end
        end

        def search_fields
          params[:attributes]
        end

        def model_name
          model&.name || params[:model]
        end

        def result_fields
          (params[:attributes] + [params[:value]]).uniq
        end

        def user_permitted?(column)
          user&.permissions&.include?(permission_for(column.name))
        end

        def authorized_user?
          missing_permissions.empty?
        end

        def permission_for(field)
          self.class.permission_for(model: model, field: field)
        end

        def authorized_model?
          TextSearch.authorized_text_searches.any? do |authorized_model, search_fields, value_field|
            next false unless authorized_model == model
            next false unless authorized_fields?(search_columns, Array(search_fields))
            next false unless authorized_fields?(Array(value_column), Array(value_field))

            true
          end
        end

        def authorized_fields?(columns, fields)
          columns.all? { |column| fields.map(&:to_sym).include?(column.name.to_sym) }
        end
      end
    end
  end
end
