# Page Subtitle

Like the [`page_title`](page-title.html) component, `page_subtitle` provides a simple heading tag.

```rspec:html
subject do
  active_element.component.page_subtitle 'Introduction'
end

it { is_expected.to include 'Introduction' }
```
