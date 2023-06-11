# Types

The following _JSON_ primitives are supported in schema definitions. Note that `null` cannot be specified as a field type, but it is the default value for most types.

|Type|Description|Ruby Mapping
|-|-|
| `object` | A key-value data construct. | `Hash` (`{}`)
| `array` | An ordered sequence of objects of any type | `Array` (`[]`)
| `string` | A sequence of _Unicode_ characters | `String` (`""`)
| `boolean` | A `true` or `false` value | `TrueClass` or `FalseClass` (`true`, `false`)
| `float` | A floating-point number | `Float` (`0.1`)
| `null` | An empty value | `NilClass` (`nil`)

And the following extensions are provided:

|Type|Description|Ruby Mapping
|-|-|
| `date` | An [iso8601 date](https://en.wikipedia.org/wiki/ISO_8601#Dates) stored as `YYYY-MM-DD`. | `Date`
| `datetime` | An [iso8601-1:2019 combined date and time](https://en.wikipedia.org/wiki/ISO_8601#Combined_date_and_time_representations) stored as `YYYY-MM-DDThh:mm:ss` | `DateTime`
| `time` | An [iso8601-1:2019 time](https://en.wikipedia.org/wiki/ISO_8601#Times) stored as `hh:mm` | `String` ([*](#time-of-day))
| `decimal` | An infinite-precision decimal object stored as a string, e.g. `"3.141592653589793"` | `BigDecimal`
| `integer` | A whole number, stored as a _JSON_ `float`. | `Integer`

Defining types in your schema allows you to work directly with _Ruby_ objects when the form is submitted to a controller. The `params` arrive pre-parsed in formats that match the automatic serialization that _ActiveRecord_ performs. e.g. converting a `DateTime` object to _JSON_ in _Rails_ outputs the following:

```irb
irb(main):001:0> puts({ time: Time.now.utc }.to_json)

{"time":"2023-06-12T20:13:11.308Z"}
```

## Time of Day

Note that _Ruby_ has no native way to store a time of day without a date, so `time` fields are coerced to `String` (`hh:mm`) when processed into controller params.

You may find the [Tod](https://github.com/JackC/tod) gem useful when working with these values.
