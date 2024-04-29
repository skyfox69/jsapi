# Jsapi

## Why Jsapi?

Jsapi is a good choice when you want to build a Rails application providing JSON APIs
consumed by one ore more clients. You can use Jsapi to read requests, produce responses
and create OpenAPI documents. All of that can be specified at one place.

Jsapi supports OpenAPI 2.0, 3.0 and 3.1.

## Installation

Add the following line to `Gemfile` and run `bundle install`.

```ruby
gem 'jsapi', git: 'https://github.com/dmgoeller/jsapi', branch: 'main'
```

## Getting started

### Creating an API operation

Create the route for the API operation in `config/routes.rb`. For example, a
non-resourceful route for a simple echo operation can be defined as below.

```ruby
# config/routes.rb

get 'echo', to: 'echo#index'
```

Create a controller that inherits from `Jsapi::Controller::Base`:

```ruby
# app/controllers/echo_controller.rb

class EchoController < Jsapi::Controller::Base
end
```

Define the API operation:

```ruby
class EchoController < Jsapi::Controller::Base
  api_operation path: '/echo' do
    parameter 'call', type: 'string', existence: true
    response 200 do
      property 'echo', type: 'string'
    end
    response 400 do
      property 'status', type: 'integer'
      property 'message', type: 'string'
    end
  end
end
```

Create the action performing the API operation. There are several options to
do this. The easiest way to implement an API operation is:

```ruby
class EchoController < Jsapi::Controller::Base
  # ...

  def index
    api_operation! status: 200 do |api_params|
      Echo.new("#{api_params.call}, again")
    end
  end
end
```

`api_operation!` passes the parameters as a lightweight API model to the block
and renders the JSON representation of the object returned by the block. If the
parameters are invalid, a `Jsapi::Controller::ParametersInvalid` exception is
raised.

To render error responses, a rescue handler can be added:

```ruby
class EchoController < Jsapi::Controller::Base
  # ...

  api_rescue Jsapi::Controller::ParametersInvalid, with: 400

  # ...
end
```

The whole controller class could look like:

```ruby
# app/controllers/echo_controller.rb

class EchoController < Jsapi::Controller::Base
  Echo = Struct.new(:echo)

  api_rescue Jsapi::Controller::ParametersInvalid, with: 400

  api_operation path: '/echo' do
    parameter 'call', type: 'string', existence: true
    response 200 do
      property 'echo', type: 'string'
    end
    response 400 do
      property 'status', type: 'integer'
      property 'message', type: 'string'
    end
  end

  def index
    api_operation! status: 200 do |api_params|
      Echo.new("#{api_params.call}, again")
    end
  end
end
```

An instance of the `EchoController` class would respond to `GET /echo?call=Hello`
with HTTP status code 200. The response body would be:

```json
{
  "echo": "Hello, again"
}
```

If the `call` query parameter isn't present, it responds with HTTP status code
400. The response body would be:

```json
{
  "status": 400,
  "message": "'call' can't be blank."
}
```

### Creating the OpenAPI documentation

Create the route for the OpenAPI document, for example:

```ruby
# config/routes.rb

get 'openapi', to: 'openapi#index'
```

Create the controller:

```ruby
# app/controllers/openapi_controller.rb

class OpenapiController < Jsapi::Controller::Base
  api_include EchoController

  openapi '3.1' do
    info title: 'Echo', version: '1'
  end

  def index
    render(json: api_definitions.openapi_document('3.1'))
  end
end
```

## Jsapi DSL

The following class methods are provided to define API components:

- [api_operation](#defining-api-operations) - Defines a single API operation.
- [api_parameter](#defining-reusable-parameters) - Defines a reusable parameter.
- [api_response](#defining-reusable-responses) - Defines a reusable response.
- [api_schema](#defining-reusable-schemas) - Defines a reusable schema.
- [api_rescue_from](#defining-rescue-handlers) - Defines a rescue handler.
- api_include - Includes API definitions from other classes.

These methods can be integrated into a controller class by inheriting from
`Jsapi::Controller::Base` or including `Jsapi::DSL`. The `Jsapi::DSL` module
can also be included in any other class.

API components can also be defined inside an `api_definitions` block,
for example:

```ruby
api_definitions do
  operation 'foo' do
    parameter 'bar'
    response 'FooResponse'
  end

  parameter 'bar', type: 'string'

  response 'FooResponse', schema: 'Foo'

  schema 'Foo', type: 'object' do
    property 'bar', type: 'string'
  end
end
```

The names and types of API components can be strings or symbols. All options
except `type` can also be specified inside the block, for example:

```ruby
# Define option as keyword argument
parameter 'foo', type: 'string', existence: true

# Define option inside the block
parameter 'bar', type: 'string' do
  existence true
end
```

### Defining operations

An operation can be defined as below.

```ruby
api_operation 'foo' do
  parameter 'bar', type: 'string'
  response do
    property 'foo', type: 'string'
  end
end
```

The operation name can be omitted, if the controller handles one operation only.

**Keywords**

- `:model` - See [API models](#api-models).
- `:method` - The HTTP verb of the operation.
- `:path` - The relative path of the operation.
- `:tags` - One or more tags used to group operations in an OpenAPI document.
- `:summary` - A short summary of the operation.
- `:description` - A desciption of the operation.
- `:deprecated` - Specifies whether or not the operation is deprecated.

### Defining parameters

A (top-level) parameter of an operation can be defined as below.

```ruby
api_operation 'foo' do
  parameter 'bar', type: 'string'
end
```

It is also possible to define nested object parameters in place.

```ruby
api_operation 'foo' do
  parameter 'bar' do
    property 'foo', type: 'string'
  end
end
```

**Keywords**

- `:schema` - See [Reusable schemas](#reusable-schemas)
- `:type` - See [The type option](#the-type-option).
- `:existence` - See [The existence option](#the-existence-option).
- `:default` - The default value.
- `:conversion` - See [The conversion option](#the-conversion-option).
- `:model` - See [API models](#api-models).
- `:items` - See [The items option](#the-items-option).
- `:format` - See [The format option](#the-format-option).
- `:in` - The location of the parameter.
- `:description` - A description of the parameter.
- `:example` - See [Defining examples](#defining-examples).
- `:deprecated` - Specifies whether or not the parameter is deprecated.

Additionally, all of the [validation options](#validation-options) can
be specified to validate top-level parameter values.

### Defining request bodies

The request body of an operation can be defined as below.

```ruby
api_operation 'foo' do
  request_body do
    property 'bar', type: 'string'
  end
end
```

**Keywords**

- `:schema` - See [Reusable schemas](#reusable-schemas)
- `:existence` - See [The existence option](#the-existence-option).
- `:default` - The default value.
- `:description` - A description of the request body.
- `:example` - See [Defining examples](#defining-examples).
- `:deprecated` - Specifies whether or not the request body is deprecated.

### Defining responses

A response of an operation can be defined as below.

```ruby
api_operation 'foo' do
  response 200 do
    property 'bar', type: 'string'
  end
end
```

**Keywords**

- `:schema` - See [Reusable schemas](#reusable-schemas)
- `:type` - See [The type option](#the-type-option).
- `:existence` - See [The existence option](#the-existence-option).
- `:items` - See [The items option](#the-items-option).
- `:format` - See [The format option](#the-format-option).
- `:locale` - The locale used when rendering the response.
- `:description` - A description of the response.
- `:example` - See [Defining examples](#defining-examples).
- `:deprecated` - Specifies whether or not the response is deprecated.

### Defining properties

A property can be defined as below.

```ruby
property 'foo', type: 'string'
```

It is also possible to define nested objects in place.

```ruby
property 'foo' do
  property 'bar', type: 'string'
end
```

**Keywords**

- `:schema` - See [Reusable schemas](#reusable-schemas)
- `:type` - See [The type option](#the-type-option).
- `:existence` - See [The existence option](#the-existence-option).
- `:default` - The default value.
- `:conversion` - See [The conversion option](#the-conversion-option).
- `:source` - The method to read a property value.
- `:model` - See [API models](#api-models).
- `:items` - See [The items option](#the-items-option).
- `:format` - See [The format option](#the-format-option).
- `:description` - A description of the property.
- `:example` - See [Defining examples](#defining-examples).
- `:deprecated` - Specifies whether or not the property is deprecated.

Additionally, all of the [validation options](#validation-options) can
be specified to validate nested parameter values.

### Defining examples

A simple sample value can be specified as below.

```ruby
property 'foo', type: 'string', example: 'bar'
```

It is also possible to define multiple sample values.

```ruby
schema 'Foo', type: 'object' do
  property 'foo', type: 'string'

  example 'foo', value: { 'foo' => 'foo' }
  example 'bar', value: { 'foo' => 'bar' }
end
```

**Keywords**

- `value` - The sample value
- `external` - Specifies whether `value` is the URI of an external example.
- `summary` - A short summary of the example.
- `description` - A description of the example.

### Defining rescue handlers

Rescue handlers are used to render error responses on errors. A rescue handler
can be defined as below.

```ruby
api_rescue_from Jsapi::Controller::ParametersInvalid, with: 400
```

### Defining OpenAPI documents

All additional data required to generate OpenAPI documents can be specified as below.

```ruby
openapi do
  info title: 'Foo', version: 1
  security_scheme 'http_basic', type: 'basic'
  security 'http_basic'

  # OpenAPI 2.0
  host 'https://foo.bar'
  base_path '/foo'

  # OpenAPI 3.0
  server url: 'https://foo.bar/foo'
end
```

### Reusable schemas

The `api_schema` method defines a schema that can be associated with
parameters, request bodies, responses and properties.

```ruby
api_schema 'Foo' do
  property 'bar', type: 'string'
end

api_operation do
  parameter 'foo', schema: 'Foo'
end
```

The properties of a schema can be included in another schema by calling
the `all_of` method.

```ruby
api_schema 'Bar' do
  all_of 'Foo'
end
```

### Reusable parameters

The `api_parameter` method defines a parameter that can be used in
multiple operations.

```ruby
api_parameter 'foo', type: 'string'

api_operation do
  parameter 'foo'
end
```

### Reusable responses

The `api_response` method defines a response that can be used in
multiple operations.

```ruby
api_response 'Foo' do
  property 'bar', type: 'string'
end

api_operation do
  response 'Foo'
end
```

### The `:type` option

The `:type` option specifies the type of a parameter, request body, response,
parameter or schema. The supported types correspond to JSON Schema:

- `array`
- `boolean`
- `integer`
- `number`
- `object`
- `string`

The default type is `object`.

### The `:existence` option

The `:existence` option combines the presence concepts of Rails and JSON Schema
by four levels of existence:

- `:present` or `true` -  The parameter or property value must not be empty.
- `:allow_empty` - The parameter or property value can be empty, for example `''`.
- `:allow_nil` or `allow_null` - The parameter or property value can be `nil`.
- `:allow_omitted` or `false` - The parameter or property can be omitted.

The default level of existence is `false`.

Note that `existence: :present` slightly differs from Rails `present?` as it
treats `false` to be present.

### The `:conversion` option

The `conversion` option can be used to convert an integer, number or string by
a method or a `Proc`, for example:

```ruby
parameter 'foo', type: 'string', conversion: :upcase
```

### The `:items` option

The `:items` options specifies the kind of items that can be contained in an
array, for example:

```ruby
parameter 'foo', type: 'array', items: { type: 'string' }
```

```ruby
parameter 'foo', type: 'array' do
  items do
    property 'bar', type: 'string'
  end
end
```

### The `:format` option

The `:format` option specifies the format of a string. Possible values are:

- `date`
- `date-time`

Parameter and property values are implictly casted to an instance of `Date`
or `DateTime` if `:format` is specified.

### Validation options

The following options can be specified to validate parameter values. The
validation options correspond to JSON Schema validations.

- `:enum` - The valid values.
- `:minimum` - The minimum value of an integer or a number.
- `:maximum` - The maximum value of an integer or a number.
- `:multiple_of` - The value an integer or a number must be a multiple of.
- `:min_length` - The minimum length of a string.
- `:max_length` - The maximum length of a string.
- `:pattern` - The regular expression a string must match.
- `:min_items` - The minimum length of an array.
- `:max_items` - The maximum length of an array.

The minimum and maximum value can be specified as shown below.

```ruby
# Restrict values to positive integers
parameter 'foo', type: 'integer', minimum: 1

# Restrict values to positive numbers
parameter 'bar', type: 'number', minimum: { value: 0, exclusive: true }
```

## API controllers

An API controller class must either inherit from `Jsapi::Controller::Base` or
include `Jsapi::Controller::Methods`.

```ruby
class FooController < Jsapi::Controller::Base
  # ...
end
```

```ruby
class FooController < ActionController::API
  include Jsapi::Controller::Methods
  # ...
end
```

Note that `Jsapi::Controller::Base` inherits from `ActionController::API` and
includes `Jsapi::DSL` as well as `Jsapi::Controller::Methods`.

The `Jsapi::Controller::Methods` module provides the following methods to deal
with API operations:

- [api_params](#the-api_params-method)
- [api_response](#the-api_response-method)
- [api_operation](#the-api_operation-method)
- [api_operation!](#the-api_operation-method-1)
- [api_definitions](#the-api-definitions-method)

### The `api_params` method

`api_params` can be used to read request parameters by an instance of an
operation's model class. The request parameters are casted according the
operation's `parameter` and `request_body` specifications.

```ruby
params = api_params('foo')
```

The one and only positional argument specifies the name of the API operation.
It can be omitted if the controller handles one API operation only.

Note that each call of `api_params` returns a newly created instance. Thus, the
instance returned by `api_params` must be locally stored when validating request
parameters, for example:

```ruby
if (params = api_params).valid?
  # ...
else
  full_messages = params.errors.full_messages
  # ...
end
```

### The `api_response` method

`api_response` can be used to serialize an object according to one of the
API operation's `response` specifications.

```ruby
render(json: api_response(foo, 'foo', status: 200))
```

The second positional argument specifies the name of the API operation.
It can be omitted if the controller handles one API operation only. `status`
specifies the HTTP status code of the response to be selected. If `status`
is not present, the default response of the API operation is selected.

### The `api_operation` method

`api_operation` performs an API operation by calling the given block. The
request parameters are passed as an instance of the operation's model class
to the block. `api_operation` implicitly renders the JSON representation of
the object returned by the block.

```ruby
api_operation('foo', status: 200) do |api_params|
  raise BadRequest if api_params.invalid?

  # ...
end
```

The one and only positional argument specifies the name of the API operation.
It can be omitted if the controller handles one API operation only. `status`
specifies the HTTP status code of the response to be selected. If `status`
is not present, the default response of the API operation is selected.

If an exception is raised while performing the block, an error response
according to the first matching rescue handler is rendered. If no matching
rescue handler could be found, the exception is raised again.

### The `api_operation!` method

Like `api_operation`, except that a `Jsapi::Controller::ParametersInvalid`
exception is raises if the request parameters are invalid.

```ruby
api_operation!('foo') do |api_params|
  # ...
end
```

Note that the exception can be catched by a rescue handler to render an
error response.

### The `api_definitions` method

`api_definitions` returns the API definitions of the controller class. This
method can be used to render an OpenAPI document.

```ruby
render(json: api_definitions.openapi_document)
```

### Strong parameters

The `api_operation`, `api_operation!` and `api_params` methods take a `:strong`
option that specifies whether or not request parameters that can be mapped are
accepted only.

```ruby
api_params('foo', strong: true)
```

The model returned is invalid if there are any request parameters that cannot be
mapped to a parameter or a request body property of the API operation. For each
parameter that cannot be mapped an error is added to the model. The pattern of
error messages can be customized using I18n as below.

```yaml
# config/en.yml
en:
  jsapi:
    errors:
      forbidden: "{name} is forbidden"
```

The default pattern is `{name} isn't allowed`.

## API models

Top-level parameters and nested object parameters are wrapped by instances of
`Jsapi::Model::Base` by default. To add custom model methods this class can be
extended within the specification of an API component, for example:

```ruby
api_schema 'IntegerRange' do
  property 'range_begin', type: 'integer'
  property 'range_end', type: 'integer'

  model do
    def range
      @range ||= (range_begin..range_end)
    end
  end
end
```

To use custom model methods in two or more API components, a subclass of
`Jsapi::Model::Base` can be integrated as below.

```ruby
class BaseRange < Jsapi::Model::Base
  def range
    @range ||= (range_begin..range_end)
  end
end
```

```ruby
api_schema 'IntegerRange', model: BaseRange do
  property 'range_begin', type: 'integer'
  property 'range_end', type: 'integer'
end

api_schema 'DateRange' do
  property 'range_begin', type: 'string', format: 'date'
  property 'range_end', type: 'string', format: 'date'

  model BaseRange do
    def expired?
      range_end.past?
    end
  end
end
```

A model class may also have validations, for example:

```ruby
class BaseRange < Jsapi::Model::Base
  validate :end_greater_than_or_equal_to_begin

  private

  def end_greater_than_or_equal_to_begin
    return if range_begin.blank? || range_end.blank?

    if range_end < range_begin
      errors.add(:range_end, :greater_than_or_equal_to, count: range_begin)
    end
  end
end
```
