# frozen_string_literal: true

RSpec.describe ActiveElement::PermissionsCheck do
  subject(:permissions_check) do
    described_class.new(
      required: required,
      actual: actual,
      action_name: action_name,
      controller_path: controller_path,
      rails_component: instance_double(ActiveElement::RailsComponent, **rails_options)
    )
  end

  let(:rails_options) { { application_name: 'example_application', environment: 'production' } }
  let(:required) { [['example_permission', options]] }
  let(:options) { {} }
  let(:actual) { %w[example_permission can_view_example_application_examples] }
  let(:action_name) { 'show' }
  let(:controller_path) { 'examples' }
  let(:application_name) { 'example_application' }

  its(:permitted?) { is_expected.to be true }

  its(:message) do
    is_expected.to eql 'User access granted for permission(s): ' \
                       'can_view_example_application_examples, example_permission'
  end

  context 'with no applicable permissions' do
    let(:required) { [] }
    let(:action_name) { 'non_restful_action' }

    it 'raises error' do
      expect { permissions_check }.to raise_error ActiveElement::UnprotectedRouteError
    end
  end

  context 'with applicable permissions not met by actual permissions' do
    let(:required) { [['example_permission', {}]] }
    let(:actual) { [] }

    its(:permitted?) { is_expected.to be false }

    its(:message) do
      is_expected.to eql 'User access forbidden. Missing user permission(s): ' \
                         'can_view_example_application_examples, example_permission'
    end
  end

  context 'with `only` option for current action' do
    let(:options) { { only: :index } }
    let(:actual) { %w[example_permission can_update_example_application_examples] }
    let(:action_name) { 'update' }

    its(:permitted?) { is_expected.to be false }
  end

  context 'with `only` option for other action' do
    let(:options) { { only: :index } }
    let(:actual) { %w[example_permission can_view_example_application_examples] }
    let(:action_name) { 'show' }

    its(:permitted?) { is_expected.to be true }
  end

  context 'with `except` option for current action' do
    let(:options) { { except: :index } }
    let(:actual) { %w[example_permission can_view_example_application_examples] }
    let(:action_name) { 'show' }

    its(:permitted?) { is_expected.to be true }
  end

  context 'with `except` option for other action' do
    let(:options) { { except: :index } }
    let(:actual) { %w[example_permission can_update_example_application_examples] }
    let(:action_name) { 'update' }

    its(:permitted?) { is_expected.to be false }
  end

  context 'with `except` option for current custom action' do
    let(:options) { { except: :custom } }
    let(:actual) { %w[example_permission] }
    let(:action_name) { 'custom' }

    it 'raises UnprotectedRouteError' do
      expect { permissions_check }.to raise_error ActiveElement::UnprotectedRouteError,
                                                  'Examples#custom must be protected with `permit_user`'
    end
  end
end
