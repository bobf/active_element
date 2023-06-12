# Forms

An interface for creating forms is provided by `active_element.component.form`, available in all views.

The `Form` component delegates to _Rails'_ `form_with` so any keyword arguments not processed by _ActiveElement_ can be passed as usual.

Forms in _ActiveElement_ provide a number of features designed to save you time and help you create powerful and flexible forms with minimal effort:

* Validation errors are automatically rendered for each form element when using _ActiveRecord_ objects or any object that implements `#errors`, `#valid?`, etc.
* Form inputs are inferred from the database column type of each field specified in the `fields` array.
* A powerful [_JSON_ editor](forms/fields/json.html) is provided for editing complex _JSON_ objects with user-friendly form elements.
* Clean and consistent layout.

See the [full keyword argument specification](forms/options.html) for information on the various available options and see the [Fields](forms/fields.html) section for documentation on each individual field type.

## Basic Example

```rspec:html
subject do
  active_element.component.form model: User.new,
                                fields: [:name, :email, :enabled]
end

it { is_expected.to include '<label for="user_name">' }
```
