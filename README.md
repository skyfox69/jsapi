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

## Getting Started

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
      parameter 'text', type: 'string', required: true
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
- `api_definitions`: Common API definitions
- `api_include`: Include API definitions from other classes

API operations, parameters and schemas can also be defined inside an
`api_definitions` block, for example:

```ruby
  api_definitions do
    operation 'foo' do
      parameter 'bar', '$ref': :bar
      response '$ref': :FooResponse
    end

    parameter 'bar', type: 'string'

    schema :FooResponse, type: 'object' do
      property 'foo', type: 'string'
    end
  end
```

The names and types of operations, parameters, schemas and properties can be
strings or symbols. All options except `type` can also be defined inside the
block, for example:

```ruby
  parameter 'foo', type: 'string', min_length: 1

  parameter 'bar', type: 'string' do
    min_length 1
  end
```

### Common Options

The following options are available for parameters, responses, schemas and
properties:

- `type`: 'array', 'boolean', 'integer', 'number', 'object' or 'string'
- `nullable`
- `default`
- `items` ('array' only)

#### JSON Schema Validations

The following options are available for parameters, responses and schemas:

- `enum`
- `minimum` (only 'integer' and 'number')
- `maximum` (only 'integer' and 'number')
- `exclusive_minimum` (only 'integer' and 'number')
- `exclusive_maximum` (only 'integer' and 'number')
- `format`: `date` or `date-time` (only 'string')
- `min_length` (only 'string')
- `max_length` (only 'string')
- `pattern` (only 'string')
- `schema`

#### Annotations

The following options are available for operations, parameters, responses and
schemas:

- `Description`
- `Example` (all except operation)

### Additional Operation Options

For OpenAPI documentation only:

- `method` (default: 'get')
. `path`
- `tags`
- `summary`
- `deprecated`

For OpenAPI documentation only:

- `in`: 'path' or 'query'
- `required`
- `deprecated`

### Additional Request Body Options

For OpenAPI documentation only:

- `required`

### Additional Property Options

- `source`

For OpenAPI documentation only:

- `required`
- `deprecated`

## Controller Methods

The `Jsapi::Controller::Methods` module provides the following methods:

- api_params
- api_response
- api_operation
- api_definitions

### The api_params Method

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

### The api_response Method

`api_response` can be used to serialize an object according to one of the
`response` definitions of the specified API operation. The operation name can
be omitted if the controller handles one API operation only.

```ruby
  render(json: api_response(bar, :foo, status: 200))
```

If `status` is not not specified, the default response of the API operation
is selected.

### The api_operation Method

`api_operation` combines `api_params` and `api_response`. It yields the
parameters returned by `api_params` to the specified block and implicitly
serializes the object returned by the block.

```ruby
  api_operation(:foo) do |api_params|
    raise BadRequest, api_params.errors.full_message if api_params.invalid?

    bar(api_params)
  end
```

### The api_operation Method

`api_definitions` returns the API definitions of the controller class. It can
be used to render an OpenAPI document.

```ruby
  render(json: api_definitions.openapi_document)
```
