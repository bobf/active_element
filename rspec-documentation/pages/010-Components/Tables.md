# Tables

An interface for creating tables is provided by `active_element.component.table`, available in all views.

The two table types provided are [Collection Table](tables/collection-table.html) and [Item Table](tables/item-table.html).

See the [full keyword argument specification](tables/options.html) for information on the various available options.

## Basic Example

```rspec:html
collection = [
  User.new(name: 'John', email: 'john@example.com', enabled: true),
  User.new(name: 'Jane', email: 'jane@example.org', enabled: false),
  User.new(name: 'Peter', email: 'peter@example.org', enabled: false),
  User.new(name: 'Sally', email: 'sally@example.org', enabled: true),
]

subject do
  active_element.component.table collection: collection,
                                 fields: [:name, :email, :enabled],
                                 show: true,
                                 new: true,
                                 edit: true,
                                 destroy: true
end

it { is_expected.to include 'John' }
```
