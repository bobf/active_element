# frozen_string_literal: true

RSpec.describe ActiveElement::Components::Button do
  subject(:button) do
    described_class.new(controller, record, flag_or_options, type: type, method: method, float: float, **kwargs)
  end

  before { allow(controller).to receive(:request) { request } }

  let(:request) { ActionDispatch::Request.new({}) }
  let(:controller) { ExamplesController.new }
  let(:record) { nil }
  let(:flag_or_options) { { title: 'Button Title', path: '/path/to/resource' } }
  let(:type) { :primary }
  let(:method) { nil }
  let(:float) { nil }
  let(:kwargs) { {} }

  it { is_expected.to be_a described_class }
  its(:template) { is_expected.to eql 'active_element/components/button' }

  describe '#locals' do
    subject(:locals) { button.locals }

    its([:controller]) { is_expected.to eql controller }
    its([:method]) { is_expected.to be :get }
    its([:path]) { is_expected.to eql '/path/to/resource' }
    its([:title]) { is_expected.to eql 'Button Title' }
    its([:button_class]) { is_expected.to eql 'btn-primary' }
    its([:float_class]) { is_expected.to be_nil }
    its([:kwargs_class]) { is_expected.to be_nil }
    its([:kwargs]) { is_expected.to eql({}) }

    context 'with :show type, record, and `true` flag' do
      let(:record) { Example.new(id: 1000) }
      let(:type) { :show }
      let(:flag_or_options) { true }

      its([:path]) { is_expected.to eql '/examples/1000' }
      its([:title]) { is_expected.to eql 'View' }
      its([:method]) { is_expected.to be :get }
      its([:button_class]) { is_expected.to eql 'btn-primary show-button action-button' }
    end

    context 'with :edit type, record, and `true` flag' do
      let(:record) { Example.new(id: 1000) }
      let(:type) { :edit }
      let(:flag_or_options) { true }

      its([:path]) { is_expected.to eql '/examples/1000/edit' }
      its([:title]) { is_expected.to eql 'Edit' }
      its([:method]) { is_expected.to be :get }
      its([:button_class]) { is_expected.to eql 'btn-primary edit-button action-button' }
    end

    context 'with :new type, record, and `true` flag' do
      let(:record) { Example.new }
      let(:type) { :new }
      let(:flag_or_options) { true }

      its([:path]) { is_expected.to eql '/examples/new' }
      its([:title]) { is_expected.to eql 'Create New Example' }
      its([:method]) { is_expected.to be :get }
      its([:button_class]) { is_expected.to eql 'btn-primary new-button action-button' }
    end

    context 'with :destroy type, record, and `true` flag' do
      let(:record) { Example.new(id: 1000) }
      let(:type) { :destroy }
      let(:flag_or_options) { true }

      its([:path]) { is_expected.to eql '/examples/1000' }
      its([:title]) { is_expected.to eql 'Delete' }
      its([:method]) { is_expected.to be :delete }
      its([:button_class]) { is_expected.to eql 'btn-danger destroy-button action-button' }
    end
  end
end
