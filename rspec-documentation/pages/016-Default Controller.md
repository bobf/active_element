# Default Controller

The default controller in _ActiveElement_ provides all the standard _Rails_ actions:

* `#index`
* `#show`
* `#new`
* `#create`
* `#edit`
* `#update`
* `#destroy`

All controllers that inherit from `ActiveElement::ApplicationController` automatically receive these routes, but they must be explicitly enabled in order to serve content, otherwise a default `403 Forbidden` page will be rendered.

Each controller expects to find a model whose name corresponds to the controller, in line with typical _Rails_ conventions. For example, if you have a `RestaurantsController` then _ActiveElement_ will expect to find a `Restaurant` model. Each of the declarations covered below describe interactions with a corresponding model.

Depending on which declarations are defined in your controllers, you will see different _UI_ elements (e.g. a _Delete_ button for each record will only be present when `active_element.deletable` has been called).

## Associations

Model associations are supported, so you can list database columns as well as relations defined on your model.

Here's a basic example:

```ruby
# app/models/restaurant.rb

class Restaurant < ApplicationRecord
  belongs_to :restaurateur
end
```

```ruby
# app/models/restaurateur.rb

class Restaurateur < ApplicationRecord
  has_many :resaturants
end
```

```ruby
# app/controllers/restaurants_controller.rb

class RestaurantsController < ApplicationController
  active_element.listable_fields :name, :restaurateur, :created_at
end
```

Now when you browse to `/restaurants` you'll see a link to each restaurants owner in the rendered table.

## Listable Fields

The `active_element.listable_fields` declaration provides a list of fields on your model that should be displayed in the default `#index` view.

A table of results will be rendered containing each record corresponding for the corresponding record, including _View_, _Edit_, and _Delete_ buttons, as well as a button above the table to create a new record.

The `order` keyword allows you to sort the results by a given field. This value is passed directly to the `ActiveRecord` `order` method, so you can use `:name` or `{ name: :desc }` or any other variation that `ActiveRecord` accepts.

```ruby
# app/controllers/restaurants_controller.rb

class RestaurantsController < ApplicationController
  active_element.listable_fields :name, :restaurateur, :created_at, order: :name
end
```

As mentioned above, associations are supported, so the `restaurateur` association will automatically map to the associated record and you'll be provided with a link to that record in the results table.

Pagination is also provided by the default `#index` action.

## Searchable Fields

The `active_element.searchable_fields` declaration provides a list of fields on your model that can be searched by a user. You can specify `string`, `integer`, and `datetime` fields.

A search form is generated and user input is processed according to column type.

* `string` fields generate an `ILIKE` (case-insensitive `LIKE`) query from user input: `"joh"` will match `"John Smith"`.
* `integer` fields require an exact match.
* `datetime` fields provide a range, allowing users to provide a start date/time, an end date/time, or both.
* Association fields will join on the relevant association and search all `string` and `integer` fields defined in the `searchable_fields` for the controller corresponding to the association model.

```ruby
# app/controllers/restaurants_controller.rb

class RestaurantsController < ApplicationController
  active_element.searchable_fields :name, :restaurateur, :created_at
end
```

```ruby
# app/controllers/restaurateurs_controller.rb

class RestaurateursController < ApplicationController
  active_element.searchable_fields :name, :address
end
```

## Viewable Fields

The `active_element.viewable_fields` declaration provides a list of fields on your model that will be included when viewing an individual record via the `#show` action.

The results will be rendered in a horizontal table with one row for each item, including a _Delete_ and _Edit_ button above the table.

```ruby
# app/controllers/restaurants_controller.rb

class RestaurantsController < ApplicationController
  active_element.searchable_fields :name, :restaurateur, :created_at
end
```

## Editable Fields

The `active_element.editable_fields` declaration provides a list of fields on your model that can be modified by a user.

This declaration enables both the `#edit`, `#new`, `#update`, and `#create` actions as well as defining the permitted parameters for `#update` and `#create`. A form is automatically generated and each field is selected according to the column data type.

Note that each field type can be overridden and configured by defining `config/forms/<model>/<field.yml>`, allowing you to make many customizations to each field without having to work with views or override the default controller actions, as well as allowing each field configuration to be re-used in multiple places. See the [Form Fields](components/form-fields.html) documentation for more details.

By default, `json` and `jsonb` fields use the [JSON Field](form-fields/json.html) type, allowing you to edit complex _JSON_ data structures via user-friendly _HTML_ forms. A [schema file](form-fields/json/schema.html) **must** be defined for these fields. See the `json_field` documentation for more details.

## Deletable

The `active_element.deletable` declaration does not receive any arguments but specifies that a record can be deleted by a user.

```ruby
# app/controllers/restaurants_controller.rb

class RestaurantsController < ApplicationController
  active_element.deletable
end
```
