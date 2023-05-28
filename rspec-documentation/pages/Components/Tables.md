# Tables

## Collection Table

The _Collection Table_ component provides a vertical table containing a collection of items item. Use with _Active Record_ model instances, an array of objects that extend `ActiveModel::Naming`, or simple hash-like objects.

Field types are automatically inferred from their respective database columns and rendered using an appropriate formatter.

```rspec:html
class User < ActiveRecord::Base
end

collection = [
  User.new(name: 'John', email: 'john@example.com'),
  User.new(name: 'Jane', email: 'jane@example.org')
]

html = active_element.component.table collection: collection, fields: [:name, :email]

it_documents html do
  expect(html).to include 'John'
end
```

## Item Table

The _Item Table_ component provides a horizontal table containing a single item and its attributes. It supports the same item types as [Collection Tables](##Collection Table).

```rspec:html
class User < ActiveRecord::Base
end

item = User.new(name: 'John', email: 'john@example.com', overview: 'Writes Ruby code for a living.')

html = active_element.component.table item: item, fields: [:name, :email, :password, :secret]

it_documents html do
  expect(html).to include 'John'
end
```

```rspec
foo = { foo: 'bar', baz: 'qux' }
it_documents foo do
  expect('hello').to eql 'hello'
end
```
