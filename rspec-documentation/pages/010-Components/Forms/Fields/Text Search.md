# Text Search

_ActiveElement_ provides a `text_search_field` capable of generating a full text search auto-suggest widget in a form.

The `text_search_field` accepts user input and presents a list of matching options, setting the field's `value` to a value specified by the field's configuration.

For example, you may want a `user_id` field that allows users to search by `name` and `email` on the `User` model, and returning the `id` for the selected result.

The field requires some extra configuration to prevent leaking unwanted data to the front end, and to allow you to select which columns should be searched and which column should be submitted to your controller as the field's `value`.

## Configuration

### Inline

To allow re-use and to prevent cluttering your views, it is recommended to use [file-based configuration](#file-based), but inline configuration is also available.

We'll make a form that creates a `Pet` record and associates it with a `User` by setting a `user_id` field.

```rspec:html
subject do
  active_element.component.form model: Pet.new,
                                fields: [
                                  :name,
                                  :animal,
                                  [:user_id,
                                   :text_search_field,
                                   { search: { model: :user, attributes: [:name, :email], value: :id } }]
                                ]
end

it { is_expected.to include 'Search...' }
```

### File-based
