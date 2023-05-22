# frozen_string_literal: true

namespace :active_element do
  desc 'Displays all permissions used by this application'
  task permissions: :environment do
    ActiveElement.eager_load_controllers
    routes = ActiveElement::Routes.new(rails_component: ActiveElement::RailsComponent.new(Rails))
    permissions = routes.map(&:permissions).flatten.sort.uniq
    $stdout.puts ActiveElement::ColorizedString.new(
      "\nThe following user permissions are used by this application:\n",
      color: :light_blue
    ).value
    permissions.each do |permission|
      color = { list: :cyan, view: :blue, create: :green, delete: :red, edit: :yellow }.find do |action, _|
        permission.include?("_#{action}_")
      end&.last || :purple
      $stdout.puts('    ' \
                   "#{ActiveElement::ColorizedString.new('*', color: :white).value} " \
                   "#{ActiveElement::ColorizedString.new(permission, color: color).value}")
    end
    $stdout.puts
  end
end
