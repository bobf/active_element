# frozen_string_literal: true

namespace :active_element do
  desc 'Display all permissions used by this application'
  task permissions: :environment do
    $stdout.puts ActiveElement::PermissionsReport.new.report
  end

  namespace :json do
    desc 'Generate JSON form field schema from database values'
    task schema: :environment do
      if ENV.key?('table') && ENV.key?('column')
        ActiveElement::JsonFieldSchema.new(table: ENV.fetch('table'), column: ENV.fetch('column'))
      else
        warn(Paintbrush.paintbrush { red "Expected #{cyan 'table'} and #{cyan 'column'} environment variables." })
      end
    end
  end
end
