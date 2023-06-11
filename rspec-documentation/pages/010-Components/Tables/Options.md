# Options

Tables receive the following keyword arguments:

| Keyword | Description |
|-|-|
| `collection` | A collection of objects. Must be iterable, e.g. the result of calling `where` on an _ActiveRecord_ model. Renders a [Collection Table](tables/collection-table.html)
| `item` | A single object. Renders an [Item Table](tables/item-table.html). Note that you must use either `collection` or `item` but not both.
| `fields` | _(Required)_ An array specifying the fields to display in the table. The keys specified in this array can be either hash keys or _ActiveRecord_ attribute names.
| `model_name` | Pass `model_name` if you are not using _ActiveRecord_ objects, e.g. if you are passing a hash or array of hashes, `model_name` should be provided to provide decorators, translations, CSS classes, etc. This argument should be omitted for _ActiveRecord_ objects (or any object that implements `ActiveModel::Naming`. |
| `class_name` | Provide an explicit class name to override the default derived from the received _ActiveRecord_ model class or the `model_name` parameter.
| `show` | A _boolean_ value specifying whether to display a _Show_ button in a `collection` table. The path for the link is derived from the received _ActiveRecord_ object, e.g. `user_path(record)`
| `destroy` | A _boolean_ value specifying whether to display a _Delete_ button for each record in a `collection` table or for the single record in an `item` table. Links to e.g. `user_path(record, method: :delete)`
| `edit` | A _boolean_ value specifying whether to display an _Edit_ button. Links to e.g. `edit_user_path(record)`
| `new` | A _boolean_ value specifying whether to display a "Create new ..." button above a `collection` table. Links to e.g. `new_user_path`
| `style` | Specify a _CSS_ string to be inserted into the `<table>` tag.
| `row_class` | Specify a class to be inserted into each `<tr>` tag in a `collection` table. Can be a `String` or a `Proc`. A `Proc` will receive the record as an argument, e.g.: `row_class: ->(record) { record.deleted_at.present? 'text-danger' : 'text-primary' }`
| `group` | Group rows in a `collection` by a given attribute, e.g.: `group: :country_code`.
| `paginate` | Enable or disable pagination for `collection` tables. Defaults to `true`.
