# frozen_string_literal: true

class ApplicationController < ActiveElement::ApplicationController
  prepend_before_action :authenticate

  private

  def authenticate
    active_element.authenticate_with { authenticate_user! }
    active_element.authorize_with { current_user }
  end
end
