# Page Title

The `page_title` component provides a simple `<h2>` tag. It's very basic but it gives you a consistent way to generate page titles that can be amended later to include any classes that you want to apply to all instances of the component.

```rspec:html
subject do
  active_element.component.page_title 'Welcome to ActiveElement'
end

it { is_expected.to include 'Welcome to ActiveElement' }
```
