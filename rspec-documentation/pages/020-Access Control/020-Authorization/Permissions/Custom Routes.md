# Custom Routes

If you have any routes defined that do not fall under the routes automatically defined by _Rails_ with the `resources` routes helper (i.e. anything other than `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`) you **must** have an explicit permission configuration defined. This design choice is intended to reduce the risk of accidental exposure of sensitive data by defaulting to having all routes protected. _ActiveElement_ will raise `ActiveEleement::UnprotectedRouteError` if an unprotected route is defined.

_ActiveElement_ provides `active_element.permit_action`, available in all controllers that inherit from `ActiveElement::ApplicationController`.

Use this helper to define a permission that a user must have in order to access a route or, if the route is intended to be available for any signed-in user, specify that it is always permitted.

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActiveElement::ApplicationController
  prepend_before_action :configure_authentication

  private

  def configure_authentication
    active_element.authenticate_with { authenticate_user! }
    active_element.authorize_with { current_user }
  end
end
```

```ruby
# app/controllers/bookings_controller.rb

class BookingsController < ApplicationController
  active_element.permit_action :export_csv, with: 'can_export_bookings_csv'
  active_element.permit_action :remaining_tickets, always: true

  def export_csv
    # ...
  end

  def remaining_tickets
    # ...
  end
end
```

In this example, `#export_csv` is only accessible to users with the `can_export_bookings_csv` permission, and `#remaining_tickets` is always available to any who has passed initial authentication.
