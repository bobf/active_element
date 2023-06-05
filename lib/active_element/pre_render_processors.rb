# frozen_string_literal: true

require_relative 'pre_render_processors/json'

module ActiveElement
  # Collection of processors called before the controller flow is handed back to the host
  # application, i.e. before actions within the main ActiveElement before action, e.g. used for
  # processing JSON fields.
  module PreRenderProcessors
  end
end
