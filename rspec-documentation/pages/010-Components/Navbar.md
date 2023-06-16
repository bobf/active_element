# Navbar

A default _Navbar_ is provided automatically for any controllers that inherit from `ActiveElement::ApplicationController` and included in the default [Layout](../layout.html).

The _Navbar_ is generated from `#index` routes for all _ActiveElement_ controllers.

For example, if you have a `BookingsController` and `UsersController` that both inherit from `ActiveElement::Controller` (either directly or via common parent controller that inherits from `ActiveElement::ApplicationController`) and provide an `#index` action, your _Navbar_ will contain links for _Users_ and _Bookings_.

The _Navbar_ brand is calculated from the name of the application `module` as defined in `config/application.rb`.

If you wish to override the default _Navbar_ configuration, create an initializer and set your desired options:

```ruby
# config/initializers/active_element.rb

ActiveElement.application_name = 'My Bookings System'
ActiveElement.navbar_items = [
  { label: 'Bookings', path: '/bookings' },
  { label: 'Users', path: '/users' },
  { label: 'New Booking', path: '/bookings/new' }
]
```

Note that overriding the default `navbar_items` means that all _Navbar_ items must now be manually configured and _ActiveElement_ will not infer any new items as new controllers/routes are added to your application.
