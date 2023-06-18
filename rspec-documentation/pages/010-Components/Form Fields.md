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
