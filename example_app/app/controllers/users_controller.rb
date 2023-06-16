class UsersController < ApplicationController
  active_element.editable_fields :name, :email, :password, :password_confirmation
  active_element.viewable_fields :name, :email, :created_at, :updated_at
  active_element.listable_fields :name, :email, :created_at, :updated_at
end
