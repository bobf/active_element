# Options

Forms receive the following keyword arguments. Any other arguments are passed to the underlying `form_with` call used to generate the form.

| Keyword | Description |
|-|-|
| `fields` | An `Array` of `Symbol`. Specifies the fields to render in the form. If a `model` keyword is used then this enables automatic type inference, otherwise the default field type is `text_field`. Pass an array of two-element arrays to specify a specific field type, e.g. `fields: [[:name, :text_field]]`. See [fields](fields.html) documentation for available field types.
| `item` | Optionally pass a `Hash` instead of using `model`. This is useful for e.g. creating a form for generating search parameters.
| `submit` | Either a `String` specifying the text to display on the submit button, or a hash with the following optional keys: `[:label, :position]`. Set `position` to one of `[:top, :bottom, :both]`, e.g.: `submit: { label: 'Create', position: :top }`.
| `title` | A `String` specifying a title text to display above the form.
| `destroy` | A boolean specifying whether to display a "Delete" button above the form. This is only useful for forms editing an existing _ActiveRecord_ object, e.g. in an `edit.html.erb` view. Defaults to `false`.
| `action` | A `String` that overrides the default action (path the form is submitted to). If this value is not passed, the value is automatically inferred from the current controller path and action: `#new` and `#create` actions to e.g. `/users`, `#edit` and `#update` actions submit to e.g. `/users/:id/edit`.
| `method` | A `String` that overrides the default method (typically `PATCH` or `POST`). Like `action`, this is automatically inferred from the current controller path and action.
| `modal` | A boolean specifying whether to provide a button that opens the form as a modal. Defaults to `false`.
| `columns` | An `Integer` specifying how many columns to use when rending form inputs. Defaults to `1`.

For typical _Rails_ _RESTful_ routing patterns using _ActiveRecord_ objects you will usually only need to specify `model` and `fields`.
