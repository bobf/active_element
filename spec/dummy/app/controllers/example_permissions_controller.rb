# frozen_string_literal: true

class ExamplePermissionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  active_element.permit_action :custom, with: :can_access_example
  active_element.permit_action :protected, with: :can_access_example

  def index
    render plain: 'List Access Granted'
  end

  def show
    render plain: 'View Access Granted'
  end

  def new
    render plain: 'New Access Granted'
  end

  def create
    render plain: 'Create Access Granted'
  end

  def edit
    render plain: 'Edit Access Granted'
  end

  def update
    render plain: 'Update Access Granted'
  end

  def destroy
    render plain: 'Delete Access Granted'
  end

  def custom
    render plain: 'Custom Access Granted'
  end

  def unprotected
    render plain: 'Unprotected Access Granted'
  end
end
