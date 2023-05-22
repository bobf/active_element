# frozen_string_literal: true

FactoryBot.define do
  factory :example do
    name { 'My Name' }
    email { 'user@example.com' }
    password { 'user-password' }
    secret { 'user-secret' }
  end
end
