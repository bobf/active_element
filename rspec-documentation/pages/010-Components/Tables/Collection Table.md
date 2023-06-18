# Collection Table

The _Collection Table_ component provides a vertical table containing a collection of items. Use with _Active Record_ model instances, an array of objects that extend `ActiveModel::Naming`, or simple hash-like objects.

Field types are automatically inferred from their respective database columns and rendered using an appropriate formatter.

Pagination (provided by [Kaminari](https://github.com/kaminari/kaminari)) is enabled by default for larger collections.

See the [full keyword argument specification](options.html) for information on the various available options.

```rspec:html
collection = [
  User.new(name: 'John', email: 'john@example.com', enabled: true),
  User.new(name: 'Jane', email: 'jane@example.org', enabled: false),
  User.new(name: 'Peter', email: 'peter@example.org', enabled: false),
  User.new(name: 'Sally', email: 'sally@example.org', enabled: true)
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
