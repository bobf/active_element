# frozen_string_literal: true

module Admin
  class ExamplesController < ActiveElement::ApplicationController
    def index
      render plain: 'Admin Examples List Access Granted'
    end

    def show
      render plain: 'Admin Examples View Access Granted'
    end
  end
end
