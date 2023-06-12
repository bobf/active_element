# Inline Decorators

In most use cases it is recommended to use [View Decorators](view-decorators.html) to render custom data to provide reusable and composable view fragments without polluting component definitions with custom logic.

However, if you need a simple one-off data transformation when using a [Table](../components/tables.html), you can specify a `Proc` within the table `fields` definition by using the secondary form of passing an `Array` of `[Symbol, Hash]` instead of just a `Symbol` for any given field.

The `Proc` will receive the current record (i.e. the object for the current row of a `collection` with a [Collection Table](../components/tables/collection-table.html) or the `item` with an [Item Table](components/tables/item-table.html)).

```rspec:html
collection = [
  User.new(name: 'John Smith', email: 'john@example.com'),
  User.new(name: 'Sally Anderson', email: 'sally@example.org')
]
subject do
  active_element.component.table collection: collection,
                                 fields: [
                                   :email,
                                   [:name, { mapper: ->(record) { record.name.upcase } }]
                                 ]
end

it { is_expected.to include 'JOHN SMITH' }
it { is_expected.to include 'SALLY ANDERSON' }
```
