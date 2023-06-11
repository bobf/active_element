## Setup

Enable authorization in your application by calling `active_element.authenticate_with` and `active_element.authorize_with` from a `prepend_before_action`. For example, if you are using [Devise](https://github.com/heartcombo/devise):

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

Adjust the provided example to suit your application's authentication framework.

As long as the following conditions are met then your application is ready to use _ActiveElement's_ authorization system:

* The method in the block sent to `active_element.authenticate_with` renders or redirects on authentication failure.
* The method in the block sent to `active_element.authorize_with` returns an object that implements a `#permissions` method which returns an array of strings.


