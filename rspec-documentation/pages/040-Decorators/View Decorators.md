# View Decorators

_View Decorators_ are _Rails_ view partials that are discovered by a conventional file path based on the model name and attribute being accessed. The partial has access to the current record, the default value, as well as all other objects typically available in _Rails_ views.

The following methods are available in a decorator's render context on top of the typical _Rails_ view context:

|Name|Description|
|-|-|
| `default` | The original, unmodified value returned directly from the model.
| `record` | The full model instance. i.e. `default` is shorthand for (e.g.) `record.name`, `record.email`, etc. depending on the given decorator definition.

To create a decorator for a `User` object's `name` attribute, create a file named `app/views/decorators/users/_name.html.erb`.

```erb
<%# app/views/decorators/users/_name.html.erb %>

<span class="name">
  <%= default %>
</span>

<% if record.created_at.present? %>
  <span class="created-at">
    (Created: <%= time_ago_in_words(record.created_at) %> ago)
  </span>
<% end %>
```

Here's an example of that exact decorator being applied to a `User` instance in an [Item Table](../../components/tables/item-table.html):

```rspec:html
user = User.create!(email: 'user@example.com', name: 'John Smith', created_at: 5.days.ago)

subject do
  active_element.component.table item: user,
                                 fields: [:email, :name]
end

it { is_expected.to include '5 days ago' }
```

## Contexts

Since _View Decorators_ are applied every time a value is displayed (note that [Forms](../../components/forms.html) always use the raw value, never the decorated value), you may need to display a value differently depending on the context. For example, you may want to display the default value in an `index` view, and you may want a customized display value in a `show` view.

If this is required, simply use an `if` statement and inspect _Rails'_ provided `controller_action` method:

```erb
<%# app/views/decorators/users/_email.html.erb %>

<% if controller_action == 'index' %>
  <%= default %>
<% else %>
  <%= mail_to default %>
<% end %>
```
