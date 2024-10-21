# Jsapi

Easily build OpenAPI compliant APIs with Rails.

## Why Jsapi?

Without Jsapi, complex API applications typically use in-memory models to read requests and
serializers to write responses. When using OpenAPI for documentation purposes, this is done
separatly.

Jsapi brings all this together. The models to read requests, the serialization of objects and
the optional OpenAPI documentation are based on the same API definition. This significantly
reduces the workload and ensures that the OpenAPI documentation is consistent with the
server-side implementation of the API.

Jsapi supports OpenAPI 2.0, 3.0 and 3.1.

## Installation

Add the following line to `Gemfile` and run `bundle install`.

```ruby
gem 'jsapi'
```

## Getting started

Start by adding a route for the API endpoint. For example, a non-resourceful route for a
simple echo endpoint can be defined as below.

```ruby
# config/routes.rb

get 'echo', to: 'echo#index'
```

Specify the operation to be bound to the API endpoint in `app/api_defs/echo.rb`:

```ruby
# app/api_defs/echo.rb

operation path: '/echo' do
  parameter 'call', type: 'string', existence: true
  response 200, type: 'object' do
    property 'echo', type: 'string'
  end
  response 400, type: 'object' do
    property 'status', type: 'integer'
    property 'message', type: 'string'
  end
end
```

Note that `existence: true` declares the `call` parameter to be required.

Create a controller that inherits from `Jsapi::Controller::Base`:

```ruby
# app/controllers/echo_controller.rb

class EchoController < Jsapi::Controller::Base
  def index
    api_operation! status: 200 do |api_params|
      {
        echo: "#{api_params.call}, again"
      }
    end
  end
end
```

Note that `api_operation!` renders the JSON representation of the object returned by the block.
This can be a hash or an object providing corresponding methods for all properties of the
response.

When the required `call` parameter is missing or the value of `call` is empty, `api_operation!`
raises a `Jsapi::Controller::ParametersInvalid` error. To rescue such exceptions, add an
`rescue_from` directive to `app/api_defs/echo.rb`:

```ruby
# app/api_defs/echo.rb

rescue_from Jsapi::Controller::ParametersInvalid, with: 400
```

To create the OpenAPI documentation for the `echo` operation, add another route, an `info`
directive and the controller action to produce OpenAPI documents, for example:

```ruby
# config/routes.rb

get 'echo/openapi', to: 'echo#openapi'
```

```ruby
# app/api_defs/echo.rb

info title: 'Echo', version: '1'
```

```ruby
# app/controllers/echo_controller.rb

class EchoController < Jsapi::Controller::Base
  def openapi
    render(json: api_definitions.openapi_document(params[:version]))
  end
end
```

The API defintions, controller and routes for the `echo` API operation look like:

- [app/api_defs/echo.rb](examples/echo/app/api_defs/echo.rb)
- [app/controllers/echo_controller.rb](examples/echo/app/controllers/echo_controller.rb)
- [config/routes.rb](/examples/echo/config/routes.rb)

An instance of the `EchoController` class responds to `GET /echo?call=Hello` with HTTP status
code 200. The response body is:

```json
{
  "echo": "Hello, again"
}
```

When the `call` parameter is missing or the value of `call` is empty, a response with HTTP
status code 400 and the following body is produced:

```json
{
  "status": 400,
  "message": "'call' can't be blank."
}
```

`GET /echo/openapi?version={2.0|3.0|3.1}` produces the following OpenAPI documents:

- [openapi-2.0.json](examples/echo/doc/openapi-2.0.json)
- [openapi-3.0.json](examples/echo/doc/openapi-3.0.json)
- [openapi-3.1.json](examples/echo/doc/openapi-3.1.json)

## Jsapi DSL

Everything needed to build an API is defined by a DSL whose vocabulary is based on OpenAPI /
JSON Schema. This DSL can be used in any controller inheriting from `Jsapi::Controller::Base`
as well as any class extending `Jsapi::DSL`. To avoid naming conflicts with other libraries,
all top-level directives start with `api_`. Therefore, the API definitions of the example in
the [Getting started](#getting-started) section can also be specified as below.

```ruby
# app/controllers/echo_controller.rb

class EchoController < Jsapi::Controller::Base
  api_info title: 'Echo', version: '1'

  api_rescue_from Jsapi::Controller::ParametersInvalid, with: 400

  api_operation path: '/echo' do
    parameter 'call', type: 'string', existence: true
    response 200, type: 'object' do
      property 'echo', type: 'string'
    end
    response 400, type: 'object' do
      property 'status', type: 'integer'
      property 'message', type: 'string'
    end
  end
end
```

Furthermore, API definitions can be specified within an `api_definitions` block as below.

```ruby
# app/controllers/echo_controller.rb

class EchoController < Jsapi::Controller::Base
  api_definitions do
    info title: 'Echo', version: '1'

    rescue_from Jsapi::Controller::ParametersInvalid, with: 400

    operation path: '/echo' do
      parameter 'call', type: 'string', existence: true
      response 200, type: 'object'  do
        property 'echo', type: 'string'
      end
      response 400, type: 'object' do
        property 'status', type: 'integer'
        property 'message', type: 'string'
      end
    end
  end
end
```

All keywords except `ref`, `schema` and `type` can also be specified as a directive,
for example:

```ruby
parameter 'call', type: 'string' do
  existence true
end
```

### Specifying operations

An operation is defined by an `api_operation` directive, for example:

```ruby
api_operation 'foo' do
  parameter 'bar', type: 'string'
  response type: 'object' do
    property 'foo', type: 'string'
  end
end
```

The one and only positional argument of the `api_operation` directive specifies the name of the
operation which can be a string or symbol. The operation name can be omitted if the controller
handles one operation only.

The `api_operation` directive takes the following keyword arguments:

- `:deprecated` - Specifies whether or not the operation is deprecated.
- `:description` - The description of the operation.
- `:method` - The HTTP verb of the operation.
- `:model` - See [API models](#api-models).
- `:path` - The relative path of the operation.
- `:summary` - The short summary of the operation.
- `:tags` - One or more tags to group operations in an OpenAPI document.

All keyword arguments except `:model` are used for documentation purposes only. The relative
path of an operation is derived from the controller name, unless it is explictly specified by
the `:path` keyword argument.

#### Parameters

A parameter of an operation is defined by a `parameter` directive within the `api_operation`
block, for example:

```ruby
api_operation do
  parameter 'foo', type: 'string'
end
```

```ruby
api_operation do
  parameter 'foo', type: 'object' do
    property 'bar', type: 'string'
  end
end
```

The one and only positional argument of the `parameter` directive specifies the mandatory
parameter name which can be a string or symbol.

The `parameter` directive takes the following keyword arguments:

- `:conversion` - See [The conversion keyword](#the-conversion-keyword).
- `:default` - The default value.
- `:deprecated` - Specifies whether or not the parameter is deprecated. Used for documentation
  purposes only.
- `:description` - The description of the parameter. Used for documentation purposes only.
- `:example` - A sample parameter value. Used for documentation purposes only.
- `:existence` - See [The existence keyword](#the-existence-keyword).
- `:format` - See [The format keyword](#the-format-keyword).
- `:in` - The location of the parameter. Possible values are `"header"`, `"path"` and `"query"`
  The default location is `"query"`.
- `:items` - See [The items keyword](#the-items-keyword).
- `:model` - See [API models](#api-models).
- `:ref` - See [Reusable parameters](#reusable-parameters).
- `:schema` - See [Schemas](#schemas).
- `:title` - The title of the parameter. Used for documentation purposes only.
- `:type` - See [The type keyword](#the-type-keyword).

Additionally, all [validation keywords](#validation-keywords) can be specified to validate
parameter values when consuming requests.

##### Reusable parameters

If a parameter is provided by multiple operations, it can be defined once by an `api_parameter`
directive, for example:

```ruby
api_parameter 'request_id', type: 'string'
```

The one and only positional argument of the `api_parameter` directive specifies the mandatory
name of the reusable parameter.

Reusable parameters can be referred by name as below.

```ruby
api_operation do
  parameter ref: 'request_id'
end
```

or

```ruby
api_operation do
  parameter 'request_id'
end
```

#### Request bodies

The optional request body of an operation is defined by a `request_body` directive within the
`api_operation` block, for example:

```ruby
api_operation 'foo' do
  request_body type: 'object' do
    property 'bar', type: 'string'
  end
end
```

The `request_body` directive takes the following keyword arguments:

- `:additional_properties` - See
  [The additional_properties keyword](#the-additional-properties-keyword).
- `:content_type`- The content type of the request body, `"application/json"` by default.
- `:default` - The default value.
- `:deprecated` - Specifies whether or not the request body is deprecated. Used for
  documentation purposes only.
- `:description` - The description of the request body. Used for documentation purposes only.
- `:example` - A sample request body. Used for documentation purposes only.
- `:existence` - See [The existence keyword](#the-existence-keyword).
- `:ref` - See [Reusable request bodies](#reusable-request-bodies).
- `:schema` - See [Schemas](#schemas).
- `:title` - The title of the request body. Used for documentation purposes only.

##### Reusable request bodies

If multiple operations have the same request body, this request body can be defined once by
an `api_request_body` directive, for example:

```ruby
api_request_body 'foo', type: 'object' do
  property 'bar', type: 'string'
end
```

The one and only positional argument of the `api_request_body` directive specifies the mandatory
name of the reusable request body.

Reusable request bodies can be referred by name as below.

```ruby
api_operation do
  request_body ref: 'foo'
end
```

or

```ruby
api_operation do
  request_body 'foo'
end
```

#### Responses

A response that may be produced by an operation is defined by a `response` directive within
the `api_operation` block, for example:

```ruby
api_operation do
  response 200 do
    property 'foo', type: 'string'
  end
end
```

The optional positional argument of the `response` directive specifies the response status.
The default response status is `default` which produces responses with HTTP status code 200.

The `response` directive takes the following keyword arguments:

- `:additional_properties` - See
  [The additional_properties keyword](#the-additional-properties-keyword).
- `:content_type`- The content type of the response, `"application/json"` by default.
- `:deprecated` - Specifies whether or not the response is deprecated. Used for documentation
  purposes only.
- `:description` - The description of the response.
- `:example` - A sample response. Used for documentation purposes only.
- `:existence` - See [The existence keyword](#the-existence-keyword).
- `:format` - See [The format keyword](#the-format-keyword).
- `:headers` - Specifies the HTTP headers of the response. Used for documentation purposes only.
- `:items` - See [The items keyword](#the-items-keyword).
- `:links` - The linked operations. Used for documentation purposes only.
- `:locale` - The locale to be used when rendering a response.
- `:ref` - See [Reusable responses](#reusable-responses).
- `:schema` - See [Schemas](#schemas).
- `:title` - The title of the response. Used for documentation purposes only.
- `:type` - See [The type keyword](#the-type-keyword).

##### Reusable responses

If a response may be produced by multiple operations, it can be defined once by an
`api_response` directive, for example:

```ruby
api_response 'error', type: 'object' do
  property 'status', type: 'integer'
  property 'detail', type: 'string'
end
```

The one and only positional argument of the `api_response` directive specifies the mandatory
name of the reusable response.

Reusable responses can be referred by name as below.

```ruby
api_operation do
  response 400, ref: 'error'
end
```

or

```ruby
api_operation do
  response 400, 'error'
end
```

#### Properties

A property of a nested parameter, request body or response is defined by a `property` directive
within the `parameter`, `request_body` or `response` block, for example:

```ruby
api_operation do
  parameter 'foo', type: 'object' do
    property 'bar', type: 'string'
  end
end
```

The `property` directive takes the following keyword arguments:

- `:additional_properties` - See
  [The additional_properties keyword](#the-additional-properties-keyword)
- `:conversion` - See [The conversion keyword](#the-conversion-keyword).
- `:default` - The default value.
- `:deprecated` - Specifies whether or not the property is deprecated. Used for documentation
  purposes only.
- `:description` -  The description of the property. Used for documentation purposes only.
- `:example` - A sample property value. Used for documentation purposes only.
- `:existence` - See [The existence keyword](#the-existence-keyword).
- `:format` - See [The format keyword](#the-format-keyword).
- `:items` - See [The items keyword](#the-items-keyword).
- `:model` - See [API models](#api-models).
- `:read_only` - Specifies whether or not the property is read only.
- `:schema` - See [Schemas](#schemas)
- `:source` - See [The source keyword](#the-source-keyword)
- `:title` - The title of the property. Used for documentation purposes only.
- `:type` - See [The type keyword](#the-type-keyword).
- `:write_only` - Specifies whether or not the property is write only.

Additionally, all of the [validation keyword](#validation-keywords) can be specified to
validate nested parameter values when consuming requests.

#### Schemas

Parameters, request bodies, responses and properties implicitly have a schema as defined by
JSON Schema. If a schema is used multiple times, it can be defined once by an `api_schema`
directive, for example:

```ruby
api_schema 'Foo', type: 'object' do
  property 'id', type: 'integer', read_only: true
  property 'bar', type: 'string'
end
```

The one and only positional argument of the `api_schema` directive specifies the mandatory
name of the reusable schema.

The `api_schema` directive takes the following keyword arguments:

- `:additional_properties` - See
  [The additional_properties keyword](#the-additional-properties-keyword)
- `:conversion` - See [The conversion keyword](#the-conversion-keyword).
- `:default` - The default value.
- `:deprecated` - Specifies whether or not the schema is deprecated. Used for documentation
  purposes only.
- `:description` -  The description of the schema. Used for documentation purposes only.
- `:example` - A sample value. Used for documentation purposes only.
- `:existence` - See [The existence keyword](#the-existence-keyword).
- `:format` - See [The format keyword](#the-format-keyword).
- `:items` - See [The items keyword](#the-items-keyword).
- `:model` - See [API models](#api-models).
- `:title` - The title of the schema. Used for documentation purposes only.
- `:type` - See [The type keyword](#the-type-keyword).

Additionally, all of the [validation keyword](#validation-keywords) can be specified.

Reusable schems can be referred by name as below.

```ruby
api_operation 'create_foo', method: 'post' do
  request_body schema: 'Foo'
  response schema: 'Foo'
end
```

##### Composition

All properties of a schema can be included in another schema by the `all_of` directive.

```ruby
api_schema 'Foo', type: 'object' do
  all_of 'Base'
end
```

##### Polymorphism

```ruby
api_schema 'Base', type: 'object' do
  discriminator property_name: 'type' do
    mapping 'foo', 'Foo'
    mapping 'bar', 'Bar'
  end
  property 'type', type: 'string', existence: true
end

api_schema 'Foo', type: 'object' do
  all_of 'Base'
  property 'foo', type: 'string'
end

api_schema 'Bar', type: 'object' do
  all_of 'Base'
  property 'bar', type: 'string'
end
```

#### Examples

A simple sample value can be specified as below.

```ruby
property 'foo', type: 'string', example: 'bar'
```

or

```ruby
property 'foo', type: 'string' do
  example 'bar'
end
```

A named sample value can be specified as below.

```ruby
property 'foo', type: 'string' do
  example 'bar', value: 'bar'
end
```

The `example` directive takes the following keyword argument:

- `description` - The description of the example.
- `external` - Specifies whether `value` is the URI of an external example.
- `summary` - The short summary of the example.
- `value` - The sample value.

#### The `:type` keyword

The `:type` keyword specifies the type of a parameter, response, property or schema. The
supported types correspond to JSON Schema:

- `array`
- `boolean`
- `integer`
- `number`
- `object`
- `string`

The default type is `object`.

#### The `:existence` keyword

The `:existence` keyword combines the presence concepts of Rails and JSON Schema
by four levels of existence:

- `:present` or `true` -  The parameter or property value must not be empty.
- `:allow_empty` - The parameter or property value can be empty, for example `''`.
- `:allow_nil` or `allow_null` - The parameter or property value can be `nil`.
- `:allow_omitted` or `false` - The parameter or property can be omitted.

The default level of existence is `false`.

Note that `existence: :present` slightly differs from Rails `present?` as it treats `false`
to be present.

#### The `:conversion` keyword

The `conversion` keyword can be used to convert integers, numbers and strings by a method or
a `Proc` when consuming requests or producing responses, for example:

```ruby
# Conversion by method
property 'foo', type: 'string', conversion: :upcase
```

```ruby
# Conversion by proc
property 'foo', type: 'string', conversion: ->(value) { value.upcase }
```

#### The `:additional_properties` keyword

The `:additional_properties` keyword defines the schema of properties that are not explicity
specified, for example:

```ruby
schema 'foo', additional_properties: { type: 'string', source: :bar }
```

The default source is `:additional_properties`.

#### The `:source` keyword

The `:source` keyword specifies the sequence of methods or the `Proc` to be called to read
property values. A source can be a string, a symbol, an array or a `Proc`, for example:

```ruby
property 'foo', source: 'bar.foo'
```

```ruby
property 'foo', source: %i[bar foo]
```

```ruby
property 'foo', source: ->(bar) { bar.foo }
```

#### The `:items` keyword

The `:items` keyword specifies the kind of items that can be contained in an
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

#### The `:format` keyword

The `:format` keyword specifies the format of a string. If the format is `"date"`,
`"date-time"` or `"duration"`, parameter and property values are implicitly
casted as below.

- `"date"` - `Date`
- `"date-time"` - `DateTime`
- `"duration"` - `ActiveSupport::Duration`

All other formats are used for documentation purposes only.

#### Validation keywords

The following keywords can be specified to validate parameter values. The validation keywords
correspond to JSON Schema validations.

- `:enum` - The valid values.
- `:max_items` - The maximum length of an array.
- `:max_length` - The maximum length of a string.
- `:maximum` - The maximum value of an integer or a number.
- `:min_items` - The minimum length of an array.
- `:min_length` - The minimum length of a string.
- `:minimum` - The minimum value of an integer or a number.
- `:multiple_of` - The value an integer or a number must be a multiple of.
- `:pattern` - The regular expression a string must match.

The minimum and maximum value can be specified as below.

```ruby
# Restrict values to positive integers
parameter 'foo', type: 'integer', minimum: 1
```

```ruby
# Restrict values to positive numbers
parameter 'bar', type: 'number', minimum: { value: 0, exclusive: true }
```

### Specifying rescue handlers

Rescue handlers are used to render error responses when an exception is raised. A rescue
handler can be defined as below.

```ruby
api_rescue_from Jsapi::Controller::ParametersInvalid, with: 400
```

To notice exceptions caught by a rescue handler a callback can be defined as below.

```ruby
api_on_rescue :foo

api_on_rescue do |error|
  # ...
end
```

### Specifying general default values

The general default values for a type can be defined as below.

```ruby
api_default 'array', within_requests: [], within_responses: []
```

`api_default` takes the following keywords:

- `:within_requests` - The general default value of parameters when consuming requests.
- `:within_responses` - The general default value of properties when producing responses.

### Specifying additional information

The following methods are provided to specify additional information:

- [api_base_path](#base-path) - Specifies the base path of the API.
- [api_callback](#reusable-callbacks) - Specifies a reusable callback.
- [api_example](#reusable-examples) - Specifies a reusable example.
- [api_external_docs](#external-documentation) - Specifies the external documentation.
- [api_header](#reusable-headers) - Specifies a reusable header.
- [api_host](#host) - Specifies the host serving the API.
- [api_info](#general-information) - Specifies general information about the API.
- [api_link](#reusable-link) - Specifies a reusable link.
- [api_scheme](#uri-scheme) - Specifies a URI scheme supported by the API.
- [api_security_requirement](#ssecurity-requirements) - Specifies a security requirement.
- [api_security_scheme](#security-schemes) - Specifies a security scheme.
- [api_server](#servers) - Specifies a server providing the API
- [api_tag](#tags) - Specifies a tag.
- [openapi_extension](#openapi-extensions)

#### General information

```ruby
api_info title: 'Foo', version: '1' do
  contact name: 'bar'
end
```

#### Servers

```ruby
api_server 'https://foo.bar/foo'
```

#### Host

```ruby
api_host 'foo.bar'
```

#### Base path

```ruby
api_base_path '/foo'
```

#### URI scheme

```ruby
api_scheme 'https'
```

#### Reusable callbacks

```ruby
api_callback 'foo' do
  operation '{$request.query.bar}', path: '/bar'
end
```

#### Reusable headers

```ruby
api_header 'foo', type: 'string'
```

#### Reusable examples

```ruby
api_example 'foo', value: 'bar'
```

#### Reusable links

```ruby
api_link 'foo', operation_id: 'bar'
```

#### Security schemes

```ruby
api_security_scheme 'basic_auth', type: 'http', scheme: 'basic'
```

#### Security requirements

```ruby
api_security_requirement do
  scheme 'basic_auth'
end
```

#### Tags

```ruby
api_tag name: 'foo', description: 'Description of foo'
```

#### External documentation

```ruby
api_external_docs url: 'https://foo.bar'
```

#### OpenAPI extensions

```ruby
openapi_extension 'foo', 'bar'
```

### Sharing API definitions

API components can be used in multiple classes by inheritance or inclusion. A controller
class inherits all API components from the parent class, for example:

```ruby
class FooController < Jsapi::Controller::Base
  api_schema 'Foo'
end

class BarController < FooController
  api_response 'Bar', schema: 'Foo'
end
```

In addition, API components from other classes can be included as below.

```ruby
class FooController < Jsapi::Controller::Base
  api_schema 'Foo'
end

class BarController < Jsapi::Controller::Base
  api_include FooController
  api_response 'Bar', schema: 'Foo'
end
```

### Importing API definitions

API definitions can also be specified in separate files located in `apps/api_defs`. Directives
within files are specified as in `api_definitions` blocks without prefix `api_`, for example:

```ruby
# app/api_defs/foo.rb

operation 'foo' do
  # ...
end
```

The API definitions specified in a file are automatically imported into a controller if the
file name matches the controller name. For example, `app/api_defs/foo.rb` is automatically
imported into `FooController`. Other files can be imported as below.

```ruby
class FooController < Jsapi::Controller::Base
  api_import 'bar'
end
```

Within a file, other files can be imported as below.

```ruby
# app/api_defs/foo/bar.rb

import 'foo/shared'
```

```ruby
# app/api_defs/foo/bar.rb

import_relative 'shared'
```

The location of API definitions can be changed by an initializer:

```ruby
# config/initializers/jsapi.rb

Jsapi.configuration.api_defs_path = 'app/foo'
```

## API controllers

An API controller class must either inherit from `Jsapi::Controller::Base` or include
`Jsapi::Controller::Methods`.

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

Note that `Jsapi::Controller::Base` inherits from `ActionController::API` and includes
`Jsapi::DSL` as well as `Jsapi::Controller::Methods`.

The `Jsapi::Controller::Methods` module provides the following methods to deal with
API operations:

- [api_params](#the-api_params-method)
- [api_response](#the-api_response-method)
- [api_operation](#the-api_operation-method)
- [api_operation!](#the-api_operation-method-1)
- [api_definitions](#the-api-definitions-method)

### The `api_params` method

`api_params` can be used to read request parameters as an instance of an operation's model
class. The request parameters are casted according the operation's `parameter` and
`request_body` specifications. Parameter names are converted to snake case.

```ruby
params = api_params('foo')
```

The one and only positional argument specifies the name of the API operation. It can be
omitted if the controller handles one API operation only.

Note that each call of `api_params` returns a newly created instance. Thus, the instance
returned by `api_params` must be locally stored when validating request parameters,
for example:

```ruby
if (params = api_params).valid?
  # ...
else
  full_messages = params.errors.full_messages
  # ...
end
```

### The `api_response` method

`api_response` can be used to serialize an object according to one of the API operation's
`response` specifications.

```ruby
render(json: api_response(foo, 'foo', status: 200))
```

The object to be serialized is passed as the first positional argument. The second positional
argument specifies the name of the API operation. It can be omitted if the controller handles
one API operation only. `status` specifies the HTTP status code of the response to be selected.
If `status` is not present, the default response of the API operation is selected.

### The `api_operation` method

`api_operation` performs an API operation by calling the given block. The request parameters
are passed as an instance of the operation's model class to the block.

This method implicitly renders the JSON representation of the object returned by the block.
This can be a hash or an object providing corresponding methods for all properties of the
response.

```ruby
api_operation('foo', status: 200) do |api_params|
  raise BadRequest if api_params.invalid?

  # ...
end
```

The one and only positional argument specifies the name of the API operation. It can be omitted
if the controller handles one API operation only. `status` specifies the HTTP status code of
the response to be selected. If `status` is not present, the default response of the API
operation is selected.

If an exception is raised while performing the block, an error response according to the first
matching rescue handler is rendered and all of the callbacks are called. If no matching rescue
handler could be found, the exception is raised again.

### The `api_operation!` method

Like `api_operation`, except that a `Jsapi::Controller::ParametersInvalid` exception is raised
on invalid request parameters.

```ruby
api_operation!('foo') do |api_params|
  # ...
end
```

The `errors` instance method of `Jsapi::Controller::ParametersInvalid` returns all of the
validation errors encountered.

### The `api_definitions` method

`api_definitions` returns the API definitions of the controller class. In particular,  this
method can be used to create an OpenAPI document.

```ruby
render(json: api_definitions.openapi_document)
```

### Strong parameters

The `api_operation`, `api_operation!` and `api_params` methods take a `:strong` option that
specifies whether or not request parameters that can be mapped are accepted only.

```ruby
api_params('foo', strong: true)
```

The model returned is invalid if there are any request parameters that cannot be mapped to a
parameter or a request body property of the API operation. For each parameter that can't be
mapped an error is added to the model. The pattern of error messages can be customized using
I18n as below.

```yaml
# config/en.yml
en:
  jsapi:
    errors:
      forbidden: "{name} is forbidden"
```

The default pattern is `{name} isn't allowed`.

## API models

By default, the parameters returned by the `params` method of a controller are wrapped by
an instance of `Jsapi::Model::Base`. Parameter names are converted to snake case. This allows
parameter values to be read by Ruby-stylish methods, even if parameter names are represented
in camel case.

Additional model methods can be added by a `model` block, for example:

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

To use additional model methods in multiple API components, a subclass of `Jsapi::Model::Base`
can be use as below.

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

api_schema 'DateRange', model: BaseRange do
  property 'range_begin', type: 'string', format: 'date'
  property 'range_end', type: 'string', format: 'date'
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
