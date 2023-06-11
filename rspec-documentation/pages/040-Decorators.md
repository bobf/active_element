# Decorators

_ActiveElement_ decorators provide a way to override the default display template for your data fields.

For example, you may want to display an icon or an image instead of the raw value from the database, or you may want to do custom formatting if the default formatters don't suit your requirements.

Decorators are implemented as _Rails_ view partials, simply create a partial in the correct location and _ActiveElement_ will use it to render your values.

Since decorators are implemented as partials, all the standard helpers and methods you're used to using in your views are avaialable.
