# frozen_string_literal: true

ActiveRecord::Migration.verbose = false

# rubocop:disable Rails/ApplicationRecord
class Example < ActiveRecord::Base
  authorize_active_element_text_search with: [:email], providing: %i[id email]

  validates :name, presence: true
  validates :email, presence: true
end
# rubocop:enable Rails/ApplicationRecord

# rubocop:disable Rails/ApplicationRecord
class UnauthorizedExample < ActiveRecord::Base; end
# rubocop:enable Rails/ApplicationRecord

module ExamplesTable
  def truncate_example_tables
    Example.connection.truncate(Example.table_name)
    UnauthorizedExample.connection.truncate(UnauthorizedExample.table_name)
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.debug { "Skipping table TRUNCATE: #{e}" }
    nil
  end

  def create_example_tables # rubocop:disable Metrics/MethodLength
    ActiveRecord::Migration.class_eval do
      create_table :examples do |t|
        t.string :name
        t.string :email
        t.string :password
        t.string :secret
      end
    end
    ActiveRecord::Migration.class_eval do
      create_table :unauthorized_examples do |t|
        t.string :email
      end
    end
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.debug { "Skipping table CREATE: #{e}" }
    nil
  end
end
