# frozen_string_literal: true

module ActiveElement
  # Stores various data for a controller, including various field definitions and authentication
  # configuration. Used throughout ActiveElement for generating dynamic content based on
  # controller configuration.
  class ControllerState
    attr_reader :permissions, :listable_fields, :viewable_fields, :editable_fields, :searchable_fields,
                :field_options
    attr_accessor :sign_in_path, :sign_in, :sign_in_method, :sign_out_path, :sign_out_method,
                  :deletable, :authorizor, :authenticator, :list_order, :search_required, :model

    def initialize(controller:)
      @controller = controller
      @permissions = []
      @authenticator = nil
      @authorizor = nil
      @deletable = false
      @listable_fields = []
      @viewable_fields = []
      @editable_fields = []
      @searchable_fields = []
      @field_options = {}
      @model = nil
    end

    def deletable?
      !!deletable
    end

    def viewable?
      viewable_fields.present? || controller.public_methods(false).include?(:show)
    end

    def editable?
      editable_fields.present? || controller.public_methods(false).include?(:edit)
    end

    def creatable?
      editable_fields.present? || controller.public_methods(false).include?(:new)
    end

    private

    attr_reader :controller
  end
end
