# Custom Controllers

The [Default Controller](default-controller.html) provides out-of-the-box functionality to get you up and running quickly, but as your application progresses you will likely need to provide custom functionality in some areas.

A custom controller is just a regular _Rails_ controller. You can still benefit from default actions provided by _ActiveElement_ and only override the specific actions you need.

In the example below we'll implement a custom `#show` action on a `UsersController` and create a custom view.

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  active_element.listable_fields :name, :email, :created_at, order: :name
  active_element.editable_fields :name, :email
  active_element.searchable_fields :name, :name, :created_at, :updated_at
  active_element.deletable

  def show
    @user = User.find(params[:id])
  end
end
```

```erb
<%# app/views/users/index.html.erb %>

<%= active_element.component.page_title 'Users' %>

<%= active_element.component.table item: @user, fields: [:email, :name, :created_at, :updated_at] %>
```

You can customize any action or view you like, simply by following standard _Rails_ patterns.
