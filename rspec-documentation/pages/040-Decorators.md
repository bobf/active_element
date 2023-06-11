# Decorators

_ActiveElement_ decorators provide a way to override the default display value for your data fields.

For example, you may want to display an icon or an image instead of the raw value from the database, or you may want to do custom formatting if the default formatters don't suit your requirements.

Decorators are implemented in two ways:

* _Rails_ view partials as [View Decorators](decorators/view-decorators.html).
* Inline `Proc` data mappers as [Inline Decorators](decorators/inline-decorators.html).

It is recommended to use _View Decorators_ instead of _Inline Decorators_ but documentation is provided for both to allow developers to make an informed decision on which solution to choose.
