# frozen_string_literal: true

RSpec.describe ActiveElement::ActiveMenuLink do
  subject(:active_menu_link) do
    described_class.new(
      rails_component: rails_component,
      controller_path: controller_path,
      action_name: action_name,
      navbar_items: navbar_items,
      current_path: current_path,
      current_navbar_item: current_navbar_item
    )
  end

  let(:rails_component) { instance_double(ActiveElement::RailsComponent) }
  let(:navbar_items) do
    [
      { label: 'Users', path: '/admin/users' },
      { label: 'Roles', path: '/admin/roles' },
      { label: 'Permissions', path: '/admin/permissions?category=admin', controller_name: 'permissions' },
      { label: 'Permissions', path: '/admin/permissions?category=api_admin', controller_name: 'permissions' },
      { label: 'Credentials', path: '/admin/applications' },
      { label: 'My Credential', path: '/admin/applications/current_user_application' },
      { label: 'Common Passwords', path: '/admin/common_passwords' },
      { label: 'Diagnostics', path: '/admin/diagnostics/new', controller_name: 'diagnostics' },
      { label: 'Expunges', path: '/admin/expunges' }
    ]
  end

  let(:route_paths_with_requirements) do
    [{ path: '/admin/users', controller: 'admin/users', action: 'index' },
     { path: '/admin/roles', controller: 'admin/roles', action: 'index' },
     { path: '/admin/permissions', controller: 'admin/permissions', action: 'index' },
     { path: '/admin/diagnostics', controller: 'admin/diagnostics', action: 'create' },
     { path: '/admin/diagnostics/new', controller: 'admin/diagnostics', action: 'new' },
     { path: '/admin/expunges', controller: 'admin/expunges', action: 'index' },
     { path: '/admin/common_passwords', controller: 'admin/common_passwords', action: 'index' },
     { path: '/admin/applications/current_user_application',
       controller: 'admin/applications', action: 'current_user_application' },
     { path: '/admin/applications', controller: 'admin/applications', action: 'index' }]
  end

  before do
    allow(rails_component).to receive(:route_paths_with_requirements) { route_paths_with_requirements }
  end

  describe '#active?' do
    subject(:active?) { active_menu_link.active? }

    context 'with exact match' do
      let(:controller_path) { 'admin/applications' }
      let(:action_name) { 'current_user_application' }
      let(:current_path) { '/admin/applications/current_user_application' }
      let(:current_navbar_item) { { path: '/admin/applications/current_user_application' } }

      it { is_expected.to be true }
    end

    context 'with partial match with no exact matches' do
      let(:controller_path) { 'admin/common_passwords' }
      let(:action_name) { 'new' }
      let(:current_path) { 'admin/common_passwords/new' }
      let(:current_navbar_item) { { path: '/admin/common_passwords', spec: { controller: 'admin/common_passwords' } } }

      it { is_expected.to be true }
    end

    context 'with partial match and no exact or near-exact matches' do
      let(:controller_path) { 'admin/applications' }
      let(:action_name) { 'new' }
      let(:current_path) { '/admin/applications/new' }
      let(:current_navbar_item) { { path: '/admin/applications', spec: { controller: 'admin/applications' } } }

      it { is_expected.to be true }
    end

    context 'with partial match with exact matches' do
      let(:controller_path) { 'admin/applications' }
      let(:action_name) { 'index' }
      let(:current_path) { '/admin/applications' }
      let(:current_navbar_item) { { path: '/admin/applications/current_user_application' } }

      it { is_expected.to be false }
    end

    context 'with no matches' do
      let(:controller_path) { 'admin/unknown_path' }
      let(:action_name) { 'index' }
      let(:current_path) { '/admin/unknown_path' }
      let(:current_navbar_item) { { path: '/admin/common_passwords' } }

      it { is_expected.to be false }
    end
  end
end
