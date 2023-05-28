require 'active_element'
require_relative 'dummy/config/environment'

RSpec::Documentation.configure do |config|
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
    end
  end

  config.context do |context|
    class StubbedController < ActiveElement::ApplicationController

      def initialize(*args, &block)
        append_view_path File.expand_path(File.join(__dir__, '../app/views/'))

        super
      end

      def params
        {}
      end
    end

    context.active_element.component = ActiveElement::Component.new(StubbedController.new)
  end
end
