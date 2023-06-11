# Permissions

In the [Setup](setup.html) example, `current_user` (typically returning an instance of an _ActiveRecord_ `User` model) must implement a method `#permissions` which returns an array of strings. You are free to implement this however you like, whether you store your permissions as a _JSON_ array in your database, in a join table, or via an external _API_ call.

_ActiveElement_ requires various inferred permissions to be present in order for a user to access a _Rails_ route. If a user does not have permissions, a splash screen appears informing the user what permissions they need to access the resource.

Permission names are based on the following templates:

|Permission Template|Relevant Controller Actions|
|`can_list_<application>_<namespace>_<controller>`|`#index`
|`can_view_<application>_<namespace>_<controller>`|`#show`
|`can_edit_<application>_<namespace>_<controller>`|`#edit`, `#update`
|`can_create_<application>_<namespace>_<controller>`|`#new`, `#create`
|`can_delete_<application>_<namespace>_<controller>`|`#destroy`

e.g. if your application is defined as:

```ruby
# config/application.rb

module BookingSystem
  class Application < Rails::Application
  end
end
```

and you have your controllers namespaced under `admin`:
```ruby
# config/routes.rb

namespace :admin do
  resources :bookings
end
```

then the following permissions will be applied:

* `can_list_booking_system_admin_bookings`
* `can_view_booking_system_admin_bookings`
* `can_edit_booking_system_admin_bookings`
* `can_create_booking_system_admin_bookings`
* `can_delete_booking_system_admin_bookings`

Note that permissions are not mapped 1:1 to controller actions. This design choice is intended to reduce the risk of e.g. revoking a permission only for the `#edit` action and being misled into thinking that this would prevent a user from submitting a request directly to the `#update` action. `#index` and `#show` are implemented as separate permissions as it is expected that one view may provide more detailed information than another.

## Listing Permissions

All permissions can be viewed at any time by running the provided _Rake_ task:

```console
$ rake active_element:permissions

* can_list_booking_system_admin_bookings
* can_view_booking_system_admin_bookings
* can_edit_booking_system_admin_bookings
* can_create_booking_system_admin_bookings
* can_delete_booking_system_admin_bookings
```
