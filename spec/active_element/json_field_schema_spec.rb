# frozen_string_literal: true

RSpec.describe ActiveElement::JsonFieldSchema do
  subject(:json_field_schema) { described_class.new(table: table, column: column) }

  let(:table) { 'examples' }
  let(:column) { 'json' }

  it { is_expected.to be_a described_class }

  describe '#schema' do
    subject(:schema) { json_field_schema.schema }

    before do
      ExamplesTable.create_example_tables
      create(:example, json: { foo: { bar: %w[baz qux] } })
    end

    it 'generates a json schema from values in a database column', pending: 'not implemented yet' do
      expect(schema.first.deep_stringify_keys.to_yaml).to eql 'TODO'
    end
  end
end
