# Authentication

Authentication is enabled by calling `active_element.authenticate_with` from a controller, typically your `ApplicationController`, or some base controller used for a restricted namespace. `active_element.authenticate_with` receives a block which calls your chosen authentication framework's user authentication.


The recommended way to handle authentication with _ActiveElement_ is to use `prepend_before_action` which calls the authenticator:

```ruby
class ApplicationController < ActionController::Base
  prepend_before_action :configure_authentication

  private

  def configure_authentication
    active_element.authenticate_with { authenticate_user! }
  end
end
```

Passing the authenticator to _ActiveElement_ is optional and you are free to handle your own authentication, but allowing _ActiveElement_ to call the authenticator is required if you wish to utilize the [authorization model](access-control/authorization.html).
