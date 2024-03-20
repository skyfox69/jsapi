# Jsapi

Provides a DSL to define JSON APIs in Rails.

The key features of _Jsapi_ are:

- Reading request parameters by generic model classes
- Serializing objects
- Creating OpenAPI and JSON Schema documents

## Installation

Add the following line to `Gemfile` and run `bundle install`.

```ruby
  gem 'jsapi', git: 'https://github.com/dmgoeller/jsapi', branch: 'main'
```

## Getting started

### Creating an API operation

Create the route for the API operation in `config/routes.rb`. For example, a
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

Define the API operation:

```ruby
  class EchoController < Jsapi::Controller::Base
    api_operation 'echo', path: '/echo' do
      parameter 'text', type: 'string', existence: true
      response do
        property 'echo', type: 'string'
      end
    end
  end
```

Add the `index` method to perform the API operation:

```ruby
  class EchoController < Jsapi::Controller::Base
    Echo = Struct.new(:echo)

    api_operation 'echo' do
      parameter 'text', type: 'string', existence: true
      response do
        property 'echo', type: 'string'
      end
    end

    def index
      params = api_params('echo')
      if params.valid?
        echo = Echo.new(api_params.text)
        render(json: api_response(echo), 'echo')
      else
        messages = params.errors.full_messages.join(' ')
        render(json: messages, status: :bad_request)
      end
    end
  end
```

or

```ruby
  class EchoController < Jsapi::Controller::Base
    Echo = Struct.new(:echo)

    api_rescue_from Jsapi::Controller::ParametersInvalid, with: 400

    api_operation 'echo', path: '/echo' do
      parameter 'text', type: 'string', existence: true
      response do
        property 'echo', type: 'string'
      end
      response 400 do
        property 'message', type: 'string'
      end
    end

    def index
      api_operation! 'echo' do |api_params|
        Echo.new(api_params.text)
      end
    end
  end
```

Both samples respond to `GET /echo?text=Hello` with:

```json
  {
    "echo": "Hello"
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
API components:

- `api_operation` - Defines a single API operation
- `api_parameter` - Defines a reusable parameter
- `api_response` - Defines a reusable response
- `api_schema` - Defines a reusable schema
- `api_rescue_from` - Defines a rescue handler
- `api_include` - Includes API definitions from other classes

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
except `type` can also be defined inside a block, for example:

```ruby
  parameter 'foo', type: 'string', existence: true

  parameter 'bar', type: 'string' do
    existence true
  end
```

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

- `model`: See [API models](#api-models)
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
- `model`: See [API models](#api-models)
- `in`: The location of the parameter, either `'path'` or `'query'` (default)
- `description`: A description of the parameter
- `example`: See [Defining examples](#defining-examples)
- `deprecated`: `true` or `false` (default)
- all of [JSON Schema validations](#json-schema-validations)

### Defining reusable parameters

```ruby
  api_parameter 'foo', type: 'string'
```

```ruby
  api_operation do
    parameter 'foo'
  end
```

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
- `model`: See [API models](#api-models)
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
- `locale`
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
- `model`: See [API models](#api-models)
- `source`
- `description`: A description of the property
- `example`: See [Defining examples](#defining-examples)
- `deprecated`: `true` or `false` (default)
- all of [JSON Schema validations](#json-schema-validations)



### Defining reusable schemas

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

## API Controllers

_Jsapi_ provides the following methods to deal with API operations:

- [api_params](#the-+api_params+-method)
- [api_response](#the-+api_response+-method)
- [api_operation](#the-+api_operation+-method)
- [api_operation!](#the-+api_operation-21+-method)
- [api_definitions](#the-+api-definitions+-method)

These methods can be integrated into a controller by inheriting from
`Jsapi::Controller::Base` or including `Jsapi::Controller::Methods`,
for example:

```ruby
  class FooController < Jsapi::Controller::Base
  end
```

or

```ruby
  class FooController < ActionController::API
    include Jsapi::Controller::Methods
  end
```

### The `api_params` method

`api_params` can be used to read request parameters by an instance of an API
operation's model class. The parameters are casted according the operation's
`parameter` and `request_body` definitions.

```ruby
  params = api_params('foo')
```

### The `api_response` method

`api_response` can be used to serialize an object according to one of the
API operation's `response` definitions.

```ruby
  render(json: api_response(foo, 'foo', status: 200))
```

If `status` is not specified, the default response of the API operation
is selected.

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

### The `api_operation!` method

Like `api_operation`, except that a `Jsapi::Controller::ParametersInvalid`
exception is raises if the request parameters are invalid.

```ruby
  api_operation!('foo') do |api_params|
    # ...
  end
```

### The `api_definitions` method

`api_definitions` returns the API definitions of the controller class. This
method can be used to render an OpenAPI document.

```ruby
  render(json: api_definitions.openapi_document)
```

# API models

Top level parameters and nested object parameters are wrapped by instances of
`Jsapi::Model::Base` by default. To add custom model methods this class can be
extended within the definition of an API component, for example:

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

The model class of an API component can also be any class that inherits from
`Jsapi::Model::Base`, for example:

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

Model classes can also contain validations, for example:

```ruby
  class BaseRange < Jsapi::Model::Base
    validate :end_greater_than_or_equal_to_begin

    private

    def end_greater_than_or_equal_to_begin
      if range_end < range_begin
        errors.add(:range_end, :greater_than_or_equal_to, count: range_begin)
      end
    end
  end
```
