# frozen_string_literal: true

namespace :active_element do
  desc 'Displays all permissions used by this application'
  task permissions: :environment do
    $stdout.puts ActiveElement::PermissionsReport.new.report
  end
end
