require 'active_element'
require_relative 'dummy/config/environment'

class UsersController < ActiveElement::ApplicationController
  def initialize(*args, &block)
    append_view_path File.expand_path(File.join(__dir__, '../app/views/'))

    super
  end

  def params
    {}
  end

  def helpers
    @helpers ||= Helpers.new
  end
end

class Helpers
  def user_path(record)
    "/user/#{record.id}"
  end

  def edit_user_path(record)
    "/user/#{record.id}/edit"
  end

  def new_user_path(*args)
    p args
    '/users/new'
  end
end

class User < ApplicationRecord
end

RSpec::Documentation.configure do |config|
  config.hook(:after_head) { File.read('rspec-documentation/_head.html') }

  ActiveRecord::Migration.class_eval do
    drop_table :users
  rescue ActiveRecord::StatementInvalid
    # Skip
  end

  ActiveRecord::Migration.class_eval do
    create_table :users do |t|
      t.string :name
      t.string :email
      t.text :overview
      t.boolean :enabled
    end
  end

  config.context do
    let(:active_element) do
      double(component: ActiveElement::Component.new(UsersController.new))
    end
  end
end
