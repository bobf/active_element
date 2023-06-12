# Authorization

_ActiveElement_ provides a comprehensive and robust authorization model to limit access to specific areas of your application to specific users. Any custom authorization not provided by _ActiveElement_ can be implemented using whatever setup you prefer, either by writing your own `before_action` methods that restrict access, e.g. by calling `head :unauthorized`, or by using a more advanced authorization framework like [Pundit](https://github.com/varvet/pundit) or [CanCanCan](https://github.com/CanCanCommunity/cancancan).

_ActiveElement_ does not attempt to replace the functionality of such frameworks and does not prevent their usage. Instead, the focus is on providing default permissions for accessing specific controller actions. Access control of particular data resources is left to the application and there are numerous high quality frameworks that provide this functionality.

If any controller inherits from `ActiveElement::ApplicationController` then it will automatically have permissions applied to all of its controller actions and, if authorization is enabled, users must have the required permissions to access. This provides an automated [least-privelege model](https://en.wikipedia.org/wiki/Principle_of_least_privilege) to all of your application's endpoints with minimal effort.

Note that actions that exist out of the standard set of _Rails_ _RESTful_ resources (i.e. `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`) **must** have an explicit permission configuration defined using `active_element.permit_action`. See [Custom Routes](authorization/permissions/custom-routes.html) for more information.

See the [Setup](authorization/setup.html) and [Permissions](authorization/permissions.html) sections to get started.
