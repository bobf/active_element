# Access Control

_ActiveElement_ provides a comprehensive authorization model for restricting access to all parts of your application based on a simple permissions system.

_ActiveElement_ does not enforce any particular authentication framework and works out of the box with [Devise](https://github.com/heartcombo/devise).

There are no restrictions on how you choose to implement your application's authentication system, but if you wish to use _ActiveElement's_ authorization model the following two methods must be defined:

* An authenticator that will render or redirect on authentication failure, e.g. _Devise's_ `authenticate_user!`.
* A user accessor that provides a user object, e.g. _Devise's_ `current_user`. The user object must respond to a `#permissions` method which returns an array of strings such as `['can_list_users']`.

A typical setup would look like this:

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  prepend_before_action :configure_authentication

  private

  def configure_authentication
    active_element.authenticate_with { authenticate_user! }
    active_element.authorize_with { current_user }
  end
end
```

_ActiveElement_ does not require authentication/authorization to be implemented and works either without any authentication at all or with your own custom authentication stack.

See the [Authentication](access-control/authentication.html) and [Authorization](access-control/authorization.html) for more details on the benefits of using the provided authorization features.
