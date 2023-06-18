# frozen_string_literal: true

RSpec.describe ActiveElement::Components::Form do
  subject(:form) { described_class.new(controller, fields: fields, submit: submit, item: item, **kwargs) }

  let(:controller) do
    instance_double(
      ActionController::Base,
      action_name: 'new',
      request: instance_double(ActionDispatch::Request, path: '/request/path'),
      controller_name: 'examples',
      helpers: helpers
    )
  end
  let(:fields) { [] }
  let(:submit) { nil }
  let(:kwargs) { {} }
  let(:item) { nil }
  let(:helpers) { double }

  before do
    allow(helpers).to receive(:'r_spec/mocks_examples_path').and_return('/examples')
  end

  it { is_expected.to be_a described_class }

  its(:template) { is_expected.to eql 'active_element/components/form' }

  describe '#locals' do
    subject(:locals) { form.locals }

    its([:component]) { is_expected.to be form }
    its([:fields]) { is_expected.to eql [] }
    its([:record]) { is_expected.to be_nil }
    its([:submit_label]) { is_expected.to eql 'Submit' }
    its([:submit_position]) { is_expected.to be :bottom }
    its([:kwargs]) { is_expected.to eql({}) }

    context 'with simple fields' do
      let(:fields) { %i[name email] }

      its([:fields]) do
        is_expected.to eql [
          [:name, :text_field, { description: nil, label: 'Name', placeholder: nil, required: false }],
          [:email, :email_field, { description: nil, label: 'Email', placeholder: nil, required: false }]
        ]
      end
    end

    context 'with fields with field types' do
      let(:fields) { [%i[name custom_field], %i[email other_custom_field]] }

      its([:fields]) do
        is_expected.to eql [
          [:name, :custom_field, { description: nil, label: 'Name', placeholder: nil, required: false }],
          [:email, :other_custom_field, { description: nil, label: 'Email', placeholder: nil, required: false }]
        ]
      end
    end

    context 'with fields with options' do
      let(:fields) do
        [
          [:name, { description: 'Description', placeholder: 'Placeholder', required: false }],
          [:email, { description: 'Other Description', label: 'Label', required: false }]
        ]
      end

      its([:fields]) do # rubocop:disable RSpec/ExampleLength
        is_expected.to eql [
          [:name, :text_field, {
            description: 'Description', label: 'Name', placeholder: 'Placeholder', required: false
          }],
          [:email, :text_field, {
            description: 'Other Description', label: 'Label', placeholder: nil, required: false
          }]
        ]
      end
    end

    context 'with fields, field types, and options' do
      let(:fields) do
        [
          [:name, :custom_field, { description: 'Description', placeholder: 'Placeholder' }],
          [:email, :other_custom_field, { description: 'Other Description', label: 'Label' }]
        ]
      end

      its([:fields]) do
        is_expected.to eql [
          [:name, :custom_field, { description: 'Description', label: 'Name', placeholder: 'Placeholder' }],
          [:email, :other_custom_field, { description: 'Other Description', label: 'Label', placeholder: nil }]
        ]
      end
    end
  end

  describe '#class_name' do
    subject(:class_name) { form.class_name }

    context 'with no class name or model provided' do
      it { is_expected.to eql '' }
    end

    context 'with class name provided' do
      let(:kwargs) { { class: 'my-class' } }

      it { is_expected.to eql 'my-class' }
    end

    context 'with model provided' do
      let(:kwargs) { { model: model } }
      let(:model) { instance_double(Class, class: model_class) }
      let(:model_class) { class_double(Class, name: 'MyModel') }

      it { is_expected.to eql 'my_model' }
    end

    context 'with class name and model provided' do
      let(:kwargs) { { model: model, class: 'my-class' } }
      let(:model) { instance_double(Class, class: model_class) }
      let(:model_class) { class_double(Class, name: 'MyModel') }

      it { is_expected.to eql 'my_model my-class' }
    end
  end

  describe '#options_for_select' do
    subject(:options_for_select) { form.options_for_select(field, field_options) }

    context 'with field and without options' do
      let(:field) { :field }
      let(:field_options) { {} }

      it 'raises ArgumentError' do
        expect { options_for_select }
          .to raise_error ArgumentError,
                          'Must provide select options `[:field, { options: [...] }]` or a record instance.'
      end
    end

    context 'with field and simple options' do
      let(:field) { :field }
      let(:field_options) { { options: %w[option1 option2] } }

      it { is_expected.to eql [['', ''], %w[option1 option1], %w[option2 option2]] }
    end

    context 'with field and options with values' do
      let(:field) { :field }
      let(:field_options) { { options: [%w[option1 value1], %w[option2 value2]] } }

      it { is_expected.to eql [['', ''], %w[option1 value1], %w[option2 value2]] }
    end

    context 'without blank field' do
      let(:field) { :field }
      let(:field_options) { { blank: false, options: [%w[option1 value1], %w[option2 value2]] } }

      it { is_expected.to eql [%w[option1 value1], %w[option2 value2]] }
    end

    context 'with field and inferred options' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:field) { :name }
      let(:field_options) { {} }
      let(:kwargs) { { model: model } }
      let(:model) { Example.new }

      before do
        truncate_example_tables
        Example.create!(name: 'foo', email: 'user@example.org')
        Example.create!(name: 'bar', email: 'user@example.com')
      end

      it { is_expected.to eql [['', ''], %w[Bar bar], %w[Foo foo]] }
    end
  end

  describe '#valid?' do
    subject(:valid?) { form.valid?(field) }

    context 'without model and without field' do
      let(:field) { nil }

      it { is_expected.to be true }
    end

    context 'with model and without field on unchanged model' do
      let(:field) { nil }
      let(:kwargs) { { model: Example.new } }

      it { is_expected.to be true }
    end

    context 'with changed model and invalid attributes' do
      let(:field) { :name }
      let(:kwargs) { { model: Example.new } }

      before { kwargs[:model].name = '' }

      it { is_expected.to be false }
    end

    context 'with valid model and without field' do
      let(:field) { nil }
      let(:kwargs) { { model: Example.new(name: 'My Name', email: 'user@example.org') } }

      it { is_expected.to be true }
    end

    context 'with some invalid attributes and without field argument' do
      let(:field) { nil }
      let(:kwargs) { { model: Example.new(name: 'My Name') } }

      it { is_expected.to be false }
    end

    context 'with valid model for attribute and with field argument' do
      let(:field) { :name }
      let(:kwargs) { { model: Example.new(name: 'My Name', email: 'user@example.org') } }

      it { is_expected.to be true }
    end

    context 'with invalid model for other attribute and with field argument' do
      let(:field) { :name }
      let(:kwargs) { { model: Example.new(name: 'My Name') } }

      it { is_expected.to be true }
    end
  end

  describe '#value_for' do
    subject(:value_for) { form.value_for(field) }

    let(:field) { :name }

    context 'without model' do
      it { is_expected.to be_nil }
    end

    context 'with model and attribute for value' do
      let(:kwargs) { { model: Example.new(name: 'My Name') } }

      it { is_expected.to eql 'My Name' }
    end

    context 'with model and without attribute for value' do
      let(:field) { :unknown_field }
      let(:kwargs) { { model: Example.new(name: 'My Name') } }

      it { is_expected.to be_nil }
    end

    context 'with item and field for value' do
      let(:field) { :name }
      let(:item) { { name: 'My Name' } }

      it { is_expected.to eql 'My Name' }
    end

    context 'with item and without field for value' do
      let(:field) { :email }
      let(:item) { { name: 'My Name' } }

      it { is_expected.to be_nil }
    end
  end

  describe '#record' do
    subject(:record) { form.record }

    context 'without model' do
      let(:kwargs) { {} }

      it { is_expected.to be_nil }
    end

    context 'with model' do
      let(:kwargs) { { model: model } }
      let(:model) { Example.new }

      it { is_expected.to eql model }
    end
  end

  describe '#model' do
    subject(:model) { form.model }

    context 'without model' do
      let(:kwargs) { {} }

      it { is_expected.to be_nil }
    end

    context 'with model' do
      let(:kwargs) { { model: model } }
      let(:model) { Example.new }

      it { is_expected.to be Example }
    end
  end
end
