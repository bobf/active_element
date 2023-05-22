# frozen_string_literal: true

RSpec.describe ActiveElement::Routes do
  subject(:routes) do
    described_class.new(permissions: permissions, rails_component: rails_component)
  end

  let(:permissions) { [] }
  let(:application_name) { 'dummy' }
  let(:rails_component) { ActiveElement::RailsComponent.new(Rails) }

  it { is_expected.to be_a described_class }

  context 'with blank permissions' do
    let(:permissions) { nil }

    its(:permitted) { is_expected.to be_empty }
    its(:first) { is_expected.to be_a ActiveElement::Route }
    its(:available) { is_expected.to all(be_a ActiveElement::Route) }
  end

  context 'with permissions matching another permitted ActiveElement route' do
    let(:permissions) { 'can_list_dummy_admin_permitted_alternatives' }

    its(:permitted) { is_expected.not_to be_empty }
    its('permitted.first.path') { is_expected.to eql '/admin/permitted_alternatives' }
  end
end
