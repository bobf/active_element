# frozen_string_literal: true

class CurrentActiveElementUser
  def permissions
    ['can_admin_api']
  end

  def type
    'Superuser'
  end

  def permission?(val)
    permissions.include?(val)
  end
end

module ApplicationHelper
  def current_user
    @current_user ||= CurrentActiveElementUser.new
  end
end
