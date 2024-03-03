# Jsapi

Provides a DSL to define JSON APIs in Rails.

**Key features:**

- Reading request parameters by objects
- Serializing objects
- Creating OpenAPI and JSON Schema documents

## Installation

Add the following line to `Gemfile` and run `bundle install`.

```ruby
  gem 'jsapi', git: 'https://github.com/dmgoeller/jsapi', branch: 'main'
```

## Getting started

### Creating an API operation

Create the route for your API operation in `config/routes.rb`. For example, a
non-resourceful route for a simple echo operation can be defined as:

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

> [!NOTE]
> `Jsapi::Controller::Base` inherits from `ActionController::API`. You can use
> _Jsapi_ also by including `Jsapi::DSL` and `Jsapi::Controller::Methods` into
> your controller.

Define your API operation:

```ruby
  class EchoController < Jsapi::Controller::Base
    api_operation path: '/echo' do
      parameter 'text', type: 'string', existence: true
      response do
        property 'echo', type: 'string'
      end
    end
  end
```

> [!NOTE]
> `path: '/echo'` and `required: true` are only used to generate a meaningful
> OpenAPI document. You can ommit this options if you don't want to generate a
> documentation for your API.

Create the method performing the API operation:

```ruby
  class EchoController < Jsapi::Controller::Base
    # ...

    def index
      if api_params.valid?
        echo = Echo.new(api_params.text)
        render(json: api_response(echo))
      else
        error_message = api_params.errors.full_message
        render(json: error_message, status: :bad_request)
      end
    end
  end
```

Assuming that `Echo` has a parameterless method `#echo` that returns the text
passed to `Echo::new`, a controller instance responds to

```
  GET /echo?text=Hello
```

with

```json
  {
    "echo": "Hello"
  }
```

If the `text` query parameter is not present, it responds with HTTP status
code 400.

### Creating the OpenAPI documentation

Create the route for your OpenAPI document, for example:

```ruby
  # config/routes.rb

  get 'openapi', to: 'openapi#index'
```

Create the controller:

```ruby
  # app/controllers/openapi_controller.rb

  class OpenapiController < Jsapi::Controller::Base
    api_definitions do
      include EchoController
      info name: 'Echo', version: '1.0'
    end

    def index
      render(json: api_definitions.openapi_document)
    end
  end
```

## Jsapi DSL

The `Jsapi::DSL` module provides the following class methods to define
JSON API components:

- `api_operation`: Defines a single API operation
- `api_parameter`: Defines a reusable parameter
- `api_schema`: Defines a reusable schema
- `api_include`: Includes API definitions from other classes

API components can also be defined inside an `api_definitions` block,
for example:

```ruby
  api_definitions do
    operation 'foo' do
      parameter 'bar'
      response schema: :FooResponse
    end

    parameter 'bar', type: 'string'

    schema :FooResponse, type: 'object' do
      property 'foo', type: 'string'
    end
  end
```

The names and types of API components can be strings or symbols. All options
except `type` can also be defined inside a block, for example:

```ruby
  parameter 'foo', type: 'string', existence: true

  parameter 'bar', type: 'string' do
    existence true
  end
```

### The `type` option

The `type` option specifies the type of a parameter, request body, response,
parameter or schema. The supported types correspond to JSON Schema:

- `array`
- `boolean`
- `integer`
- `number`
- `object` (default)
- `string`

### The `existence` option

The `existence` option combines the presence concepts of Rails and JSON Schema
by four levels of existence:

- `:present` or `true`: The parameter or property value must not be empty.
- `:allow_empty`: The parameter or property value can be empty, for example `''`.
- `:allow_nil` or `allow_null`: The parameter or property value can be `nil`.
- `:allow_omitted` or `false`: The parameter or property can be omitted.

Note that `existence: :present` slightly differs from Rails `present?` as it
treats `false` to be present.

### The `conversion` option

The `conversion` option can be used to convert an integer, number or string by
a method or a `Proc`, for example:

```ruby
  parameter 'foo', type: 'string', conversion: :upcase
  parameter 'bar', type: 'number', conversion: ->(n) { n.round(2) }
```

### The `items` option

The `items` options specifies the kind of items contained in an array,
for example:

```ruby
  parameter 'foo', type: 'array', items: { type: 'string' }

  parameter 'bar', type: 'array' do
    items type: 'object' do
      property 'foo_bar', type: 'string'
    end
  end
```

### JSON Schema validations

_Jsapi_ supports the following JSON Schema validations:

All objects:

- `enum`

Integers and number:

- `minimum`
- `maximum`
- `multiple_of`

```ruby
  parameter 'foo', type: 'integer', maximum: 9
  parameter 'bar', type: 'integer', maximum: { value: 10, exclusive: true }
```

Strings:

- `min_length`
- `max_length`
- `pattern`

Arrays:

- `min_items`
- `max_items`

### Defining API operations

Example:

```ruby
  api_operation 'foo' do
    parameter 'bar', type: 'string'
    request_body, type: 'object', existence: true do
      property 'foo', type: 'string'
    end
    response type: 'object' do
      property 'foo', type: 'string'
    end
  end
```

Options:

- `method` (default: 'get')
. `path`
- `tags`
- `summary`
- `description`
- `deprecated`

### Defining parameters

Example:

```ruby
  parameter 'foo', type: 'string', in: 'path'
```

Options:

- `type`: See [The type option](#the-type-option)
- `existence`: See [The existence option](#the-existence-option)
- `conversion`: See [The conversion option](#the-conversion-option)
- `items`: See [The items option](#the-items-option)
- `in`: The location of the parameter, either `'path'` or `'query'` (default)
- `description`: A description of the parameter
- `example`: See [Defining examples](#defining-examples)
- `deprecated`: `true` or `false` (default)
- all of [JSON Schema validations](#json-schema-validations)

### Defining request bodies

Example:

```ruby
  request_body type: 'object' do
    property 'foo', type: 'string'
  end
```

Options:

- `type`: See [The type option](#the-type-option)
- `existence`: See [The existence option](#the-existence-option)
- `conversion`: See [The conversion option](#the-conversion-option)
- `items`: See [The items option](#the-items-option)
- `description`: A description of the request body
- `example`: See [Defining examples](#defining-examples)
- `deprecated`: `true` or `false` (default)
- all of [JSON Schema validations](#json-schema-validations)

### Defining responses

Example:

```ruby
  response type: 'object' do
    property 'foo', type: 'string'
  end
```

Options:

- `type`: See [The type option](#the-type-option)
- `existence`: See [The existence option](#the-existence-option)
- `conversion`: See [The conversion option](#the-conversion-option)
- `items`: See [The items option](#the-items-option)
- `description`: A description of the response
- `example`: See [Defining examples](#defining-examples)
- `deprecated`: `true` or `false` (default)
- all of [JSON Schema validations](#json-schema-validations)

### Defining properties

Example:

```ruby
  property 'foo', type: 'string', source: :bar
```

Options:

- `type`: See [The type option](#the-type-option)
- `existence`: See [The existence option](#the-existence-option)
- `conversion`: See [The conversion option](#the-conversion-option)
- `items`: See [The items option](#the-items-option)
- `source`
- `description`: A description of the property
- `example`: See [Defining examples](#defining-examples)
- `deprecated`: `true` or `false` (default)
- all of [JSON Schema validations](#json-schema-validations)

### Defining and using reusable parameters

```ruby
  api_parameter 'foo', type: 'string'
```

```ruby
  api_operation do
    parameter 'foo'
  end
```

### Defining and using reusable schemas

```ruby
  api_schema 'Foo' do    
    property 'foo', type: 'string'    
  end
```

```ruby
  api_schema 'Bar' do
    all_of 'Foo'
  end
```

```ruby
  api_schema 'Bar' do
    property 'foo', schema: 'Foo'
  end
```

### Defining examples

```ruby
  property 'foo', type: 'string', example: 'bar'
```

```ruby
  schema 'Foo', type: 'object' do
    property 'foo', type: 'string'

    example 'foo', value: { 'foo' => 'foo' }
    example 'bar', value: { 'foo' => 'bar' }
  end
```

## Controller methods

The `Jsapi::Controller::Methods` module provides the following methods:

- api_params
- api_response
- api_operation
- api_definitions

### The `api_params` method

`api_params` can be used to read request parameters by objects providing a
method for each parameter. The request parameters are casted according to the
`parameter` definitions of the specified API operation. The operation name can
be omitted if the controller handles one API operation only.

```ruby
  api_params(:foo)
```

The request parameters can be validated by `valid?` or `invalid?`.

```ruby
  api_params = api_params(:foo)
  raise BadRequest, api_params.errors.full_message if api_params.invalid?
```

### The `api_response` method

`api_response` can be used to serialize an object according to one of the
`response` definitions of the specified API operation. The operation name can
be omitted if the controller handles one API operation only.

```ruby
  render(json: api_response(bar, :foo, status: 200))
```

If `status` is not not specified, the default response of the API operation
is selected.

### The `api_operation` method

`api_operation` combines `api_params` and `api_response`. It yields the
parameters returned by `api_params` to the specified block and implicitly
serializes the object returned by the block.

```ruby
  api_operation(:foo) do |api_params|
    raise BadRequest, api_params.errors.full_message if api_params.invalid?

    bar(api_params)
  end
```

### The `api_operation` Method

`api_definitions` returns the API definitions of the controller class. It can
be used to render an OpenAPI document.

```ruby
  render(json: api_definitions.openapi_document)
```
