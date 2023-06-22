# Introduction

_ActiveElement_ is a [Ruby on Rails](https://rubyonrails.org/) framework primarily intended for building admin applications with minimal effort.

An [authorization framework](access-control.html) is provided, intended to work alongside existing frameworks such as [Devise](https://github.com/heartcombo/devise), [Pundit](https://github.com/varvet/pundit), and [CanCanCan](https://github.com/CanCanCommunity/cancancan).

_ActiveElement_ is designed to avoid the all-or-nothing approach that many frameworks provide, allowing you to build a fully functional administration tool in minutes, while still allowing you to customize every aspect of your application. _ActiveElement_ is just a _Rails_ application with extra features: when you need to build custom functionality, you do it the same way you would any other _Rails_ application and you can use as much or as little of _ActiveElement_ as you like.

Take a look at the [Setup Guide](setup.html) to build your first _ActiveElement_ application and see how easily you can mix in standard _Rails_ behaviours.

## Highlights

* Build an entire application by defining models and controllers with just a few lines of configuration in each controller.
* [Components](components.html) that can be re-used throughout your application.
* Feature-rich [forms](components/forms.html) including a powerful [JSON form field component](components/form-fields/json.html).
* Simple and secure [auto-suggest text search](components/form-fields/text-search.html) widgets.
* [Decorators](decorators.html) for overriding default display fields with simple _Rails_ view partials.
* Automated [route-based permissions](access-control/authorization/permissions.html) that can be applied to all application endpoints with minimal effort.
* [Bootstrap](https://getbootstrap.com/) styling with [customizable themes](themes.html).

See the [Setup Guide](setup.html) and browse the rest of the documentation for full usage examples.
