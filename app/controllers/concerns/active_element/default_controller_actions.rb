# frozen_string_literal: true

module ActiveElement
  # Default Rails actions to be performed if not defined by a controller, allows developers to
  # define a controller and have basic boilerplate for typical functionality which can be
  # overridden and customized as needed.
  module DefaultControllerActions
    extend ActiveSupport::Concern

    def index
      ActiveElement::DefaultController.new(controller: self).index
    end

    def show
      ActiveElement::DefaultController.new(controller: self).show
    end

    def new
      ActiveElement::DefaultController.new(controller: self).new
    end

    def create
      ActiveElement::DefaultController.new(controller: self).create
    end

    def edit
      ActiveElement::DefaultController.new(controller: self).edit
    end

    def update
      ActiveElement::DefaultController.new(controller: self).update
    end

    def destroy
      ActiveElement::DefaultController.new(controller: self).destroy
    end
  end
end
