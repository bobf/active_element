# Page Section Title

Another very basic component, similar to [`page_title`](page-title.html) and [`page_subtitle`](page-subtitle.html).

Use this component to add a title to individual sections of your page.

```rspec:html
subject do
  active_element.component.page_section_title 'Features'
end

it { is_expected.to include 'Features' }
```
