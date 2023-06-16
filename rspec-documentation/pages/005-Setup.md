# Setup

To integrate _ActiveElement_ into your _Rails_ application, follow the steps below:

## Installation

Install the `active_element` gem by adding the following to your `Gemfile`:

```ruby
gem 'active_element'
```

Then rebuild your bundle:

```console
$ bundle install
```

## Application Controller

Inherit from `ActiveElement::ApplicationController` in the controller you want to use with _ActiveElement_. In most cases this will either be your main `ApplicationController`, or a namespaced admin area controller, e.g. `Admin::ApplicationController`.

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActiveElement::ApplicationController
  # ...
end
```

## Create a View

We'll use `UsersController` in this example, but you can replace this with whatever controller you want to use with _ActiveElement_.

Assuming your controller is defined something like this:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def index
    @users = User.all
  end
end
```

And your routes are defined something like this:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  resources :users
end
```

Edit or create `app/views/users/index.html.erb`. Add a page title and a table component:

```erb
<%# app/views/users/index.html.erb %>

<%= active_element.component.page_title 'Users' %>

<%= active_element.component.table collection: @users, fields: [:id, :email, :name] %>
```

Adjust the `fields` to match whatever attributes you want to display for each `User` in your table.

Start your _Rails_ application and browse to `/users` to see your new users index.

## Next Steps

Now that you know how to render components, take a look at the [Components](components.html) section of this documentation to see what components are available and how to use them.
