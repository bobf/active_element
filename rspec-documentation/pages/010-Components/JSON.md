# JSON

The _JSON_ component provides a mechanism for converting _Ruby_ objects and storing them as _JSON_ within your _HTML_ so that it can be later accessed by any _Javascript_ code running in your application.

The implementation is simple but is intended to avoid repetition of serialization and ensures that all _JSON_ data you output is stored consistently in one location.

_JSON_ data is available to _Javascript_ code as `ActiveElement.jsonData`. The component receives a key and an object to be serialized. The key is converted to camel case to provide conventionally-named _Javascript_ accessors.

Note that only the data key is converted to camel case. The data object itself is not transformed in any way aside from converting directly to _JSON_.

```rspec:html
subject do
  active_element.component.json :my_data, { some: { example: 'data' } }
end

it { is_expected.to include '"myData"' }
```

The data is now available to _Javascript_ code - try running the following code in your browser's _Javascript_ console:

```javascript
console.log(ActiveElement.jsonData.myData);
```
