# Controller Params

_JSON_ fields are processed by _ActiveElement_ before they arrive as controller `params`. Read the [Behind the Scenes](#behind-the-scenes) section if you want to know exactly what happens during this processing.

The result of processing the _JSON_ parameters is that you get a regular _Rails_ controller `params` object (i.e. an instance of `ActionController::Parameters`) so you can use `params.require(...).permit(...)` to manage your _JSON_ objects.

_ActiveElement_ does not automatically permit parameters but it does map types for you based on the defined [schema](schema.html). This means you don't have to manually parse dates, decimals, etc. if you need to work with them in your controller.

Each mapped type is specifically chosen to be safe to serialize back into _JSON_, so you can create a _JSON_ field, work with familiar _Ruby_ objects, and then save the objects back to your database transparently. Those saved objects can then be edited in your front end forms in the same format they were originally entered.

If you have the following schema:

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

Then your controller would look exactly like it would if you were working with vanilla _Rails_ forms:

```ruby
class UsersController < ActiveElement::ApplicationController
  def update
    @user = User.find(params[:id])
    if user.update(user_params)
      flash.notice = 'User updated'
      redirect_to user_path(@user)
    else
      flash.alert = 'User update failed'
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(pets: [:name, :age, :animal, favorite_foods: []])
  end
end
```

## Behind the Scenes

_ActiveElement_ tries to avoid behind-the-scenes magic where possible but, in this case, allowing fully transparent bi-directional _JSON_ parsing and type coercion is so convenient that we make an exception. Here's what happens when you generate a form with a _JSON_ field and then submit the form back to your _Rails_ application:

1. A `hidden` field `__json_fields[]` is created with its `value` set to the name of the field in dot notation, e.g. `user.pets`.
1. Another `hidden` field `__json_field_schemas[users][pets]` is created with its `value` set to an empty string. The front end _Javascript_ updates this when the form loads with the full schema. This ensures the data and schema are always consistent, even if the schema file changes between loading the form and submitting it.
1. Whenever the _JSON_ field is updated, the `value` for the main `input` field is set to the full state of the field's data structure, as a _JSON_ string.
1. When the form is submitted, a `before_action` in `ActiveElement::ApplicationController` intercepts the request and parses the _JSON_ data structure for any fields listed in the `__json_fields` array.
1. The resulting data structure (a _Ruby_ `Array` or `Hash`) is then traversed recursively, applying type coercion to any fields specified in the schema that require it, e.g. a `decimal` schema definition produces a `BigDecimal` for all applicable values in the data structure.
1. A new `ActionController::Parameters` object is created with all the regular fields (`text_field`, etc.) included, plus the transformed data structures for the _JSON_ fields.
1. The meta parameters `__json_fields` and `__json_field_schemas` are removed from the result. You'll see them in the logs but they won't get in the way in your controller.
1. The `request.params` object is re-assigned to the newly-constructed `ActionController::Parameters` object and the request continues as normal.

If you have worked with submitting _JSON_ to _Rails_ controllers before then you have probably done at least some of these steps manually in your controller actions. _ActiveElement_ aims to remove that manual effort and provide a `params` object that is familiar and consistent with _Rails_ conventions, so all you need to do is pass the params to your _ActiveRecord_ `create`/`update` methods and everything should work seamlessly, while also giving you the benefit of being able to work with _Ruby_ objects. If you need to sort an array of objects by date before saving back to the database then it's as simple as:

```ruby
def sorted_family
  user_params[:family].sort_by { |family_member| family_member[:date_of_birth] }
end

def user_params
  params.require(:user).permit(family: [:date_of_birth, :name, :relation])
end
```
