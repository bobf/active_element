class ApplicationController < ActiveElement::ApplicationController
  prepend_before_action :configure_authentication

  private

  def configure_authentication
    active_element.authenticate_with { authenticate_user! }
    active_element.authorize_with { current_user }
    active_element.sign_out_with(method: :delete) { destroy_user_session_path }
    active_element.sign_in_with { new_user_session_path }
  end
end
