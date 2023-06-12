# Schema

The `json_field` schema defines the shape of each _JSON_ object contained in your database.

Each model attribute has its own schema definition, each stored in a separate file for easy maintenance.

See the [Types](types.html) documentation for a list of all available types.

The schema definition requires two parameters to be present at the top level:

* `type`
* `shape`

The `type` at the top level should always be `array` or `object`.

The `shape` parameter defines the structure of your _JSON_, either each element within your _JSON_ `array` or the keys within your _JSON_ `object`.

`type` is required for all fields, and `shape` is required for all `array` and `object` fields, either at the top level or recursively at any point in your definition.

## Array of strings

An `array` of `string` objects can be defined with the following schema:

```yaml
# config/forms/user/nicknames.yml

---
type: array
shape:
  type: string
```

You can see this schema in action in the below example:

```rspec:html
subject do
  active_element.component.form model: User.new(email: 'user@example.com'),
                                fields: [:email, :nicknames]
end

it { is_expected.to include 'user[nicknames]' }
```

If you watch the _Javascript_ console in your browser, you can see the internal state updating as you edit the content (this only occurs when `ActiveElement.debug` is set to `true` in _Javascript_).

## Pre-defined options

The `string` type accepts a parameter `options` which is a list of pre-defined options that will be used to render a `select` element populated with the defined options:

```yaml
# config/forms/user/permissions.yml
---
type: array
shape:
  type: string
  options:
  - can_make_coffee
  - can_drink_coffee
  - can_discuss_coffee
```

We'll use the schema from the previous example as well and create two separate `json_field` elements, and this time we'll pre-populate the `nicknames` field with some values:

```rspec:html
subject do
  active_element.component.form model: User.new(nicknames: ["Buster", "Coffee Guy"]),
                                fields: [:email, :permissions, :nicknames]
end

it { is_expected.to include 'Coffee Guy' }
```

## Array of Objects

To define an array of objects, set the `type` parameter of the `array`'s `shape` to `object` and specify another `shape` with a list of `fields`, each with an associated `name` and `type`.

The `name` is used as the `object`'s key when the input is converted to _JSON_:

```yaml
# config/forms/user/family.yml
---
type: array
shape:
  type: object
  shape:
    fields:
    - name: relation
      type: string
      options:
      - Parent
      - Sibling
      - Spouse
    - name: name
      type: string
    - name: date_of_birth
      type: date
```

Like the previous example, we'll keep the existing fields we've defined to generate a more complex form.

We've also introduced a `date` field here, which generates an _HTML5_ `date` input field (see the [Types](types.html) section for more information on each of the available types).

```rspec:html
let(:user) do
  User.new(email: 'user@example.com',
           nicknames: ['Buster', 'Coffee Guy'],
           permissions: ['can_drink_coffee'])
end

subject do
  active_element.component.form model: user,
                                fields: [:email, :nicknames, :permissions, :family]
end

it { is_expected.to include 'Spouse' }
```

## Focus

So far things are pretty easy to manage, but if we have a user with a large family then the view will quickly become very cluttered and it will be difficult for users to navigate the form.

To keep things manageable, the `array` type has an extra parameter `focus`. Use this parameter to specify a list of fields from each `object` found in the `array`. The first _truthy_ value (e.g. a non-empty string) found on each field is displayed as a placeholder. You can specify as many fields as you like.

This time we'll use another _JSON_ column on our `User` model: `extended_family`. We'll populate it with a few more family members and we'll specify `focus` on `name` and `estranged`. The new field `estranged` is a `boolean`, which we'll use for family members whose name we've forgotten.

We'll use `Faker` to generate some random data:

```yaml
# config/forms/user/extended_family.yml
---
type: array
focus:
- name
- estranged
shape:
  type: object
  shape:
    fields:
    - name: relation
      type: string
      options:
      - Cousin
      - Aunt
      - Uncle
    - name: name
      type: string
    - name: date_of_birth
      type: date
    - name: estranged
      type: boolean
```

```rspec:html
let(:user) do
  User.new(
    email: 'user@example.com',
    nicknames: ['Buster', 'Coffee Guy'],
    permissions: ['can_make_coffee', 'can_drink_coffee', 'can_discuss_coffee'],
    extended_family: extended_family
  )
end

let(:extended_family) do
  20.times.map do
    estranged = (rand(3) % 3).zero?
    { name: estranged ? nil : Faker::Name.unique.name,
      relation: ['Cousin', 'Aunt', 'Uncle'].sample,
      date_of_birth: Faker::Date.birthday,
      estranged: estranged }
  end
end

subject do
  active_element.component.form model: user,
                                fields: [:email, :nicknames, :permissions, :extended_family]
end

it { is_expected.to include 'Coffee Guy' }
```

## Wrapping Up

Aside from the handful of special parameters for certain [Types](types.html) we've covered everything you need to know about defining a _JSON_ object schema.

To wrap things up, we'll combine all of our schemas into one single `object` schema and render a form. We'll call our field `user_data` and merge all the schemas into a single file. The only thing different about this schema compared to the others is that the top-level `type` is `object` instead of `array`. Otherwise, we're re-using all of the same mechanisms described above. Each schema was copy & pasted into the new schema under the `fields` array of the top object and a `name` was assigned to each one, otherwise they're completely unchanged.

Since we're in debug mode for this documentation, the state is logged to the _Javascript_ console each time you modify a form value, so you can see what would be submitted if this form were connected to a real application.

Make sure you read the [Controller Parameters](controller-parameters.html) section to see how to use [Rails StrongParameters](https://api.rubyonrails.org/classes/ActionController/StrongParameters.html) in conjunction with _ActiveElement_ _JSON_ fields.

```yaml
# config/forms/user/user_data.yml
---
type: object
shape:
  fields:
  - name: nicknames
    type: array
    shape:
      type: string

  - name: permissions
    type: array
    shape:
      type: string
      options:
      - can_make_coffee
      - can_drink_coffee
      - can_discuss_coffee

  - name: family
    type: array
    shape:
      type: object
      shape:
        fields:
        - name: relation
          type: string
          options:
          - Parent
          - Sibling
          - Spouse
        - name: name
          type: string
        - name: date_of_birth
          type: date

  - name: extended_family
    type: array
    focus:
    - name
    - estranged
    shape:
      type: object
      shape:
        fields:
        - name: relation
          type: string
          options:
          - Cousin
          - Aunt
          - Uncle
        - name: name
          type: string
        - name: date_of_birth
          type: date
        - name: estranged
          type: boolean
```

```rspec:html
let(:user) do
  User.new(
    email: 'user@example.com',
    user_data: {
      nicknames: ['Buster', 'Coffee Guy'],
      permissions: ['can_make_coffee', 'can_drink_coffee', 'can_discuss_coffee'],
      extended_family: extended_family
    }
  )
end

let(:extended_family) do
  20.times.map do
    estranged = (rand(3) % 3).zero?
    { name: estranged ? nil : Faker::Name.unique.name,
      relation: ['Cousin', 'Aunt', 'Uncle'].sample,
      date_of_birth: Faker::Date.birthday,
      estranged: estranged }
  end
end

subject do
  active_element.component.form model: user, fields: [:email, :user_data]
end

it { is_expected.to include 'Coffee Guy' }
```
