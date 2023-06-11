# Text Search

_ActiveElement_ provides a `text_search_field` capable of generating a full text search auto-suggest widget in a form.

The `text_search_field` accepts user input and presents a list of matching options, setting the field's `value` to a value specified by the field's configuration.

For example, you may want a `user_id` field that allows users to search by `name` and `email` on the `User` model, and returning the `id` for the selected result.

The field requires some extra configuration to prevent leaking unwanted data to the front end, and to allow you to select which columns should be searched and which column should be submitted to your controller `params` as the field's `value`.

## Example

We'll make a form that creates a `Pet` record and associates it with a `User` by setting a `user_id` field.

Click the **Rendered Output** tab and type a few characters into the search field. In the real world this would be connected to your application, but for the purpose of this documentation we've stubbed the _Javascript_ `fetch` function to return some fake results based on the input.

```rspec:html
subject do
  active_element.component.form model: Pet.new,
                                fields: [
                                  :name,
                                  :animal,
                                  [:user_id,
                                   :text_search_field,
                                   { search: { model: :user, with: [:name, :email], providing: :id } }]
                                ]
end

it { is_expected.to include 'Search...' }
```

When you select an option from the suggestions, the full display value appears in the field, but the controller only receives the `id` attribute in `params[:pet][:user_id]` - the display value is a hidden field that gets overwritten by the actual value.

## Routes

If you run `rails routes` in your project once you've set up _ActiveElement_ you'll notice an extra route added for each of your controllers:

```console
$ rails routes

Routes for ActiveElement::Engine:
pets__active_element_text_search POST /pets/_active_element_text_search(.:format)    pets#_active_element_text_search
```

These routes receive text queries and generate results based on your configuration. They're required for the `text_search_field` to work but you can safely ignore them, they are protected by [permissions](#permissions) if you have [authorization](../../../access-control/authorization) configured, as well as some [model configuration](#model-configuration) to ensure that only fields you explicitly configure are searchable.

## Configuration

### Model Configuration

Allowing users to search arbitrary columns on arbitrary models would be a major security risk. To prevent unauthorized data access and _DoS_ vulnerabilities (e.g. allowing searching unindexed database columns), _ActiveElement_ requires that models define which columns are searchable and which columns can provide values. The example above requires the following model definition in order to work:

```ruby
# app/models/user.rb

class User < ApplicationRecord
  authorize_active_element_text_search with: [:name, :email], providing: :id
end
```

Now even if an attacker sends a custom request to the text search endpoint of your application, only the `name` and `email` columns on the `users` table are searchable, while the `id` column can be returned in results but not searched.

**Important note:** Specifying columns as searchable using the `with` keyword implicitly permits their matched values to be returned in the result sent back to the front end. This is for two reasons:

1. Displaying the full matched search parameters provides a more coherent user experience. If we only return the `id`, the user won't know if they're selecting the option they're looking for.
1. Forcing the display of searched values is intended to reduce the risk of giving developers a false sense of security that only values listed in the `providing` keyword will be exposed. An attacker can use trivial techniques to gain the full value of a searchable column without being able to see it in the front end. By including the matched search values in the result, there is no ambiguity that these values are exposed to the front end application.

### Inline Configuration

To allow re-use and to prevent cluttering your views, it is recommended to use [file-based configuration](#file-based), but inline configuration is also available.

We'll re-use the example from above, breaking down exactly what's happening:

```rspec:html
subject do
  active_element.component.form model: Pet.new,
                                fields: [
                                  :name,
                                  :animal,
                                  [:user_id,
                                   :text_search_field,
                                   { search: { model: :user, with: [:name, :email], providing: :id } }]
                                ]
end

it { is_expected.to include 'Search...' }
```

First we invoke the `form` component which renders our _HTML_ form, specifying `Pet.new` as the `model`, just like a regular _Rails_ form.

The `fields` array uses the usual format for the `name` and `animal` fields - the field type will be derived from the database type for each field.

The `user_id` field is specified as an array with three elements:

1. The field name, `user_id`. This provides `params[:pet][:user_id]` when the form is submitted to the controller.
1. The field type, _ActiveElement's_ `text_search_field`.
1. An options hash, specifically including a `search` key that defines `model`, `with`, and `providing`.

It's important to clarify that specifying these fields in the view is not sufficient to provide security, since they simply provide metadata to help the front-end _Javascript_ component send the correct parameters. A user with access to the application could modify these fields and send arbitrary requests, which is why the [model configuration](#model-configuration) is required.

The `model` option translates `:user` into `User` to identify the _ActiveRecord_ model to use in the search, and the `with` and `providing` options specify the searchable fields (`with`) and the value field (`providing`). Only the `providing` field is included in the request `params`.

### File-based Configuraton

Using inline configuration is fine for one-offs and examples, but it's easy to imagine a form definition becoming cluttered with multiple search fields defined, as well as requiring duplicating and maintaining the same search fields across different forms (e.g. `edit` and `new`).

To mitigate this, file-based configuration is recommended for text search fields.

The above configuration can be redefined by creating `config/forms/pet/user_id.yml`:

```yaml
# config/forms/pet/user_id.yml

---
type: text_search_field
options:
  search:
    model: user
    with:
    - name
    - email
    providing: id
```

You can still use inline configuration to override these settings, but now the form can be defined as:

```rspec:html
subject do
  active_element.component.form model: Pet.new, fields: [:name, :animal, :user_id]
end

it { is_expected.to include 'Search...' }
```
