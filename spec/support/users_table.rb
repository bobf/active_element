# frozen_string_literal: true

module UsersTable
  def truncate_users_table
    User.connection.truncate(User.table_name)
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.debug { "Skipping table TRUNCATE: #{e}" }
    nil
  end

  # Adapted from default Devise migration.
  def create_users_table # rubocop:disable Metrics/MethodLength
    ActiveRecord::Migration.class_eval do
      create_table :users do |t|
        t.string :email,              null: false, default: ''
        t.string :encrypted_password, null: false, default: ''
        t.string :reset_password_token
        t.datetime :reset_password_sent_at
        t.datetime :remember_created_at
        t.text :permissions
        t.string :encrypted_password
      end
      add_index :users, :email,                unique: true
      add_index :users, :reset_password_token, unique: true
    end
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.debug { "Skipping table CREATE: #{e}" }
    nil
  end
end
