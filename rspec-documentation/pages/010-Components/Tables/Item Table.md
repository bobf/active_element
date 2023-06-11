# Item Table

The _Item Table_ component provides a horizontal table containing a single item and its attributes. Use with an _Active Record_ model instance, an object that extends `ActiveModel::Naming`, or a simple hash-like object.

See the [full keyword argument specification](options.html) for information on the various available options.

```rspec:html
item = User.new(name: 'John', email: 'john@example.com', overview: 'Writes Ruby code for a living.')

subject do
  active_element.component.table item: item,
                                 fields: [:name, :email, :overview],
                                 edit: true,
                                 destroy: true
end

it { is_expected.to include 'John' }
```
