# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe ActiveElement::Components::CollectionTable do
  subject(:collection_table) { described_class.new(controller, **kwargs) }

  let(:kwargs) do
    {
      class_name: class_name,
      model_name: nil,
      collection: collection,
      fields: fields,
      show: show,
      edit: edit,
      destroy: destroy,
      style: style,
      params: params
    }
  end

  let(:controller) { instance_double(ActiveElement::ApplicationController) }
  let(:class_name) { 'my-class' }
  let(:collection) { [item] }
  let(:item) { Example.new(name: 'My Name') }
  let(:fields) { [:name] }
  let(:show) { false }
  let(:edit) { false }
  let(:destroy) { false }
  let(:style) { 'font-size: 1rem;' }
  let(:params) { {} }

  before { allow(controller).to receive(:active_element) { ActiveElement::ControllerInterface.new(controller) } }

  its(:template) { is_expected.to eql 'active_element/components/table/collection' }

  describe '#locals' do
    subject(:locals) { collection_table.locals }

    its([:component]) { is_expected.to eql collection_table }
    its([:class_name]) { is_expected.to eql 'my-class' }
    its([:destroy]) { is_expected.to be false }
    its([:style]) { is_expected.to eql 'font-size: 1rem;' }

    describe '[:fields]' do
      subject(:fields_array) { locals[:fields] }

      it 'includes original field name' do
        expect(fields_array.first.first).to be :name
      end

      it 'includes generated class name' do
        expect(fields_array.first.second.call(item)).to eql 'my-class-name'
      end

      it 'includes generated label' do
        expect(fields_array.first.third).to eql 'Name'
      end

      it 'includes data mapper' do
        expect(fields_array.first.fourth).to be_a Proc
      end

      it 'includes options' do
        expect(fields_array.first.fifth).to be_a Hash
      end
    end
  end

  describe 'data mapper' do
    subject(:mapped_data_value) { collection_table.locals[:fields].first.fourth.call(item) }

    context 'with hash item' do
      let(:item) { { name: 'My Name from Hash' } }

      it { is_expected.to eql 'My Name from Hash' }
    end

    context 'with ActiveRecord item' do
      let(:item) { Example.new(name: 'My Name from Model') }

      before { allow(controller).to receive(:render_to_string) { item.name } }

      it { is_expected.to eql 'My Name from Model' }
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
