# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable

  def permissions
    return [] if self[:permissions].blank?

    JSON.parse(self[:permissions])
  end
end
