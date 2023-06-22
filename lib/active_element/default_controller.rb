# frozen_string_literal: true

require_relative 'default_controller/controller'
require_relative 'default_controller/actions'
require_relative 'default_controller/params'
require_relative 'default_controller/json_params'
require_relative 'default_controller/search'

module ActiveElement
  # Provides default boilerplate functionality for quick setup of an application.
  # Implements all standard Rails controller actions, provides parameter permitting of configured
  # fields and text search functionality.
  module DefaultController
  end
end
