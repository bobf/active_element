# Form Fields

_ActiveElement_ provides a selection of fields, most of which delegate to _Rails'_ own [form helpers](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html).

Extra field types provided by _ActiveElement_ include:

* [`json_field`](form-fields/json.html): A rich _JSON_ schema-based form generator that recursively creates form elements for your _JSON_ objects.
* [`text_search_field`](form-fields/text-search.html): A full text search/auto-suggest component that provides a secure implementation with minimal configuration.
* [`check_boxes`](form-fields/check-boxes.html): A set of checkboxes that can optionally be provided as option groups.

Other field types are inferred from the data type and/or column name for each attribute passed to the `fields` array and leverage the existing [form helpers](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html) provided by _Rails_. e.g. if you have an _ActiveRecord_ instance with an attribute whose database column type is `date`, a [date field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-date_field) will be automatically rendered. Similarly, a column named `email` will render an [`email_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-email_field).

```rspec:html
subject do
  active_element.component.form model: User.new,
                                fields: [:email, :name, :date_of_birth]
end

it { is_expected.to include 'type="date"' }
```

If you need to override these field types, use a two-element array of `[field_name, field_type]`:

```rspec:html
subject do
  active_element.component.form model: User.new,
                                fields: [:email, :name, [:date_of_birth, :text_field]]
end

it { is_expected.not_to include 'type="date"' }
```

You can also pass a third element to the array to specify any options you want to pass to the field:

```rspec:html
subject do
  active_element.component.form model: User.new,
                                fields: [
                                  :email,
                                  :name,
                                  [:date_of_birth, :text_field, { class: 'form-control my-class' }]
                                ]
end

it { is_expected.to include 'class="form-control my-class"' }
```

## Custom Fields

If you're using the [Default Controller](../default-controller.html) or you simply want to separate your configuration from your views, you can customize each form field by creating a file named `config/forms/<model>/<field>.yml`.

The `User` `email` field can be configured by creating `config/forms/user/email.yml`:

```yaml
# config/forms/user/email.yml

type: email_field
options:
  class: 'form-control my-email-field-class'
  description: 'We will use your email address to send your account details.'
  placeholder: 'Enter your email address, e.g. user@example.com'
```

```rspec:html
subject do
  active_element.component.form model: User.new,
                                fields: [:email, :name, :date_of_birth]
end

it { is_expected.to include 'class="form-control my-email-field-class"' }
```

The `options` configuration receives a small number of options specific to _ActiveElement_ such as `description` and [Text Search](form-fields/text-search.html) configuration, otherwise they are passed directly to the underlying _Rails_ form helper.

The `type` configuration corresponds to either a _Rails_ form helper _ActiveElement_ extension field, i.e. `email_field` will call some variation of:

```ruby
form_with do |form|
  form.email_field :email
end
```
