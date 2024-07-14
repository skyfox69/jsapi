# Change log

## 0.3.0 (2024-07-14)

### Breaking changes

- When wrapping parameters and serializing objects, parameter and property names
  are converted to snake case.

### New features

- Responses may contain additional properties as specified by OpenAPI.

- Support of OpenAPI extensions.

## 0.2.0 (2024-07-05)

### Breaking changes

- The `schema` method no longer takes the `schema` keyword to refer another schema, for
  example `schema 'foo', schema: 'bar'`. Instead, the `ref` keyword can be used,
  for example `schema 'foo', ref: 'bar'`.

- `api_operation!` raises an `Jsapi::Controller::ParametersInvalid` instead of a
  `ParserError` if a string can't be converted to a `Date` or `DateTime`.

### Changes

- The `:format` keyword is no longer restricted to `"date"` and `"date-time"`.

- A parameter or property value is casted to an instance of `ActiveSupport::Duration` when
  type is `"string"` and format is `"duration"`.

- The `schemes`, `host` and `basPath` fields of an OpenAPI 2.0 object are taken from the
  URL of the first server object if they are not specified explicitly.

## 0.1.2 (2024-06-28)

### Changes

- Add meta data to gemspec

## 0.1.1 (2024-05-27)

Initial version
