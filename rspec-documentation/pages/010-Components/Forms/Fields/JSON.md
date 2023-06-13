# JSON

A custom form field `json_field` is provided for editing _JSON_ data.

The field is schema-based and expects to find a schema definition in `config/forms/<model>/<attribute>.yml`.

For example, to edit a _JSON_ attribute named `permissions` on a `User` model, _ActiveElement_ requires a file named `config/forms/user/permissions.yml`.

See the [Schema](json/schema.html) documentation for a detailed description of how this file should be generated.

The `json_field` type will be automatically selected for _ActiveRecord_ `json` and `jsonb` columns included in the `fields` array when used in conjunction with an _ActiveRecord_ model.


## Example Form

This example is powered by the [example schema](#example-schema) below.

The `pets` column on the `users` table is a `json` column so _ActiveElement_ loads the schema and generates a dynamic, interactive form component allowing users to edit the data structure without having to manually edit _JSON_.

Click the "Rendered Output" tab to see it in action:

```rspec:html
let(:user) do
  User.new(
      email: 'user@example.com',
      pets: [
        { animal: 'Cat', name: 'Hercules', favorite_foods: ['Plants', 'Biscuits'] },
        { animal: 'Dog', name: 'Samson' }
      ]
  )
end

subject do
  active_element.component.form model: user, title: 'New User', fields: [:email, :pets]
end

it { is_expected.to include 'Hercules' }
```

## Example Schema

The example above is powered by this schema definition:

```yaml
# config/forms/user/pets.yml
---
type: array
shape:
  type: object
  shape:
    fields:
    - name: name
      type: string
    - name: age
      type: integer
    - name: animal
      type: string
      options:
      - Cat
      - Dog
      - Polar Bear
    - name: favorite_foods
      type: array
      shape:
        type: string
        options:
        - Biscuits
        - Plants
        - Carpet
```
