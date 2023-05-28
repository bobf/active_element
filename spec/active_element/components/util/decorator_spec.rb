# frozen_string_literal: true

RSpec.describe ActiveElement::Components::Util::Decorator do
  subject(:decorator) { described_class.new(component: component, item: item, field: field, value: value) }

  let(:component) { instance_double(ActiveElement::Components::ItemTable, controller: controller, model_name: nil) }
  let(:controller) do
    instance_double(
      ActiveElement::ApplicationController,
      render_to_string: 'decorated value'
    )
  end
  let(:item) { Example.new }
  let(:field) { :example_field }
  let(:value) { 'example value' }

  before { allow(controller).to receive(:active_element) { ActiveElement::ControllerInterface.new(controller) } }

  it { is_expected.to be_a described_class }

  describe '#decorated_value' do
    subject(:decorated_value) { decorator.decorated_value }

    let(:value) { 'undecorated value' }

    context 'with decorator present' do
      let(:field) { :email }

      it { is_expected.to eql 'decorated value' }
    end

    context 'without decorator present' do
      let(:field) { :other }
      let(:missing_template_error) do
        ActionView::MissingTemplate.new(['/example/path/'], '/another/example/path', [], true, nil)
      end

      before { allow(controller).to receive(:render_to_string).and_raise missing_template_error }

      it { is_expected.to eql 'undecorated value' }
    end
  end
end
