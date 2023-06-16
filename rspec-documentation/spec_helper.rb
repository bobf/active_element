require 'active_element'
require_relative 'dummy/config/environment'
require_relative 'support'

RSpec::Documentation.configure do |config|
  active_element = OpenStruct.new(component: ActiveElement::Component.new(UsersController.new))
  application_css = Rails.application
                         .assets
                         .find_asset('active_element/application.css')
                         .source.split("\n")
                         .drop_while { |line| !line.include?('app/assets/stylesheets/active_element') }
                         .join("\n")
  text_search_names = 1000.times.map do
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    {
      value: rand(1000),
      attributes: [
        "#{first_name}.#{last_name}@#{Faker::Internet.domain_name}".downcase,
        "#{first_name} #{Faker::Name.middle_name} #{last_name}".downcase
      ]
    }
  end

  before_content = [
    ERB.new(File.read('app/views/active_element/components/form/_templates.html.erb')).result(binding),
    ERB.new(File.read('rspec-documentation/_head.html.erb')).result(binding)
  ].join("\n")

  config.hook(:before_content) { before_content }

  ActiveRecord::Migration.class_eval do
    drop_table :users
    drop_table :pets
  rescue ActiveRecord::StatementInvalid => e
    warn e.message
  end

  ActiveRecord::Migration.class_eval do
    create_table :users do |t|
      t.string :name
      t.string :email
      t.text :overview
      t.boolean :enabled
      t.date :date_of_birth
      t.datetime :created_at
      t.json :pets
      t.json :nicknames
      t.json :permissions
      t.json :family
      t.json :extended_family
      t.json :user_data
      t.string :encrypted_password
    end
  end

  ActiveRecord::Migration.class_eval do
    create_table :pets do |t|
      t.string :name
      t.string :animal
      t.integer :user_id
    end
  end

  config.context do
    let(:active_element) do
      double(component: ActiveElement::Component.new(UsersController.new))
    end
  end
end
