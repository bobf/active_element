# Fields

_ActiveElement_ provides a selection of fields, most of which delegate to _Rails'_ own form field generators.

Extra field types provided by _ActiveElement_ include:

* [`json_field`](fields/json.html): A rich _JSON_ schema-based form generator that recursively creates form elements for your _JSON_ objects.
* [`text_search_field`](fields/text-search): A full text search/auto-suggest component that provides a secure implementation with minimal configuration.
* [`check_boxes`](fields/check-boxes.html): A set of checkboxes that can optionally be provided as option groups.

Other field types are inferred from the data type and/or column name for each attribute passed to the `fields` array and leverage the existing [form helpers](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html) provided by _Rails_. e.g. if you have an _ActiveRecord_ instance with an attribute whose database column type is `date`, a [date field](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-date_field) will be automatically rendered. Similarly, a column named `email` will render an [`email_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-email_field).

```rspec:html
subject do
  active_element.component.form model: User.new,
                                fields: [:email, :name, :date_of_birth]
end

it { is_expected.to include 'type="date"' }
```
