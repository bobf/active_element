# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'devise-user@example.org' }
    password { 'password123' }
    password_confirmation { 'password123' }
    permissions { %w[can_do_thing].to_json }
  end
end
