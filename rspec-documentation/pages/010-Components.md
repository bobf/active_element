# Components

The core of _ActiveElement_ is its set of components. These components are intended to be used within _Rails_ views to reduce the amount of _HTML_ developers need to write, as well as standardizing the look and feel of your application. A typical admin application should need very little (if any) custom _HTML_. If custom _HTML_ is needed, the composable nature of the provided components allows for this.

See the individual documentation sections for each component, and visit the [Decorators](decorators.html) section to see how you can write composable partials to override the default data formatters as needed.

All examples demonstrate how to use a component in a _Rails_ view. Every view rendered by a controller that inherits from `ActiveElement::ApplicationController` will have the `active_element` method available to them.

To use a component in your view, call (e.g.) `active_element.component.form` to render a [Form](components/form.html) component:

```erb
<%# app/views/users/new.html.erb %>

<%= active_element.component.form model: User.new, fields: [:email, :name] %>
```
