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

  def request
    @_request = Session.new
    @request ||= Request.new
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
    '/users/new'
  end
end

class Request
  def path
    '/users/new'
  end

  def host
    'www.example.com'
  end

  def optional_port
    80
  end

  def protocol
    'http'
  end

  def path_parameters
    {}
  end

  def method_missing(*)
    nil
  end
end

class Session
  def session
    {}
  end
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
      t.date :date_of_birth
      t.datetime :created_at
    end
  end

  config.context do
    let(:active_element) do
      double(component: ActiveElement::Component.new(UsersController.new))
    end
  end
end
