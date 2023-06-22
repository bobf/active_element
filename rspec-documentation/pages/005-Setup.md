# Setup

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

Inherit from `ActiveElement::ApplicationController` in the controller you want to use with _ActiveElement_. In most cases this will either be your main `ApplicationController`, or a namespaced admin area controller, e.g. `Admin::ApplicationController`. This will apply the default _ActiveElement_ layout which includes a [Navbar](components/navbar.html), [Theme Switcher](components/theme-switcher.html), and all the required _CSS_ and _Javascript_.

If you want to add custom content to the layout, see the [Hooks](hooks.html) documentation, or if you want to use a completely custom layout, simply specify `layout 'my_layout'` in your `ApplicationController`.

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActiveElement::ApplicationController
  # ...
end
```

## Default Controller Actions

_ActiveElement_ provides default controller actions for all controllers that inherit from `ActiveElement::ApplicationController` (directly or indirectly).

Each action provides boilerplate functionality to get your application off the ground as quickly as possible. See the [Default Controller](default-controller.html) for full details.

The below example creates a `/users` endpoint for your application with boilerplate to list, search, view, create, edit, and delete users:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  resources :users
end
```

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  active_element.listable_fields :name, :email, :created_at, order: :name
  active_element.viewable_fields :name, :email, :created_at, :updated_at
  active_element.editable_fields :name, :email
  active_element.searchable_fields :name, :name, :created_at, :updated_at
  active_element.deletable
end
```

```ruby
# app/models/user.rb

class User < ApplicationRecord
end
```

You can now browse to `/users` on your local development server and see all the default behaviour provided by _ActiveElement_.

See the [Default Controller](default-controller.html) and [Custom Controllers](custom-controllers.html) sections for more details.
