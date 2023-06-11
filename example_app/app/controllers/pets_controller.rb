class PetsController < ApplicationController
  active_element.listable_fields :name, :animal, :owner, :created_at, :updated_at
  active_element.viewable_fields :name, :animal, :owner, :created_at, :updated_at
  active_element.editable_fields :name, :animal, :owner
  active_element.searchable_fields :name, :animal, :owner, :created_at, :updated_at
end
