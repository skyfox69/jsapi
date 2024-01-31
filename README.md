# Jsapi

Easily build JSON APIs with Rails.

## Installation

Add the following line to `Gemfile` and run `bundle install`.

```ruby
  gem 'jsapi', git: 'https://github.com/dmgoeller/jsapi', branch: 'main'
```

## Getting Started

Create the route for an API operation in `config/routes.rb`. For example,
a non-resourceful route for a simple echo operation can be defined as:

```ruby
  # config/routes.rb

  get 'echo', to: 'echo#index'
```

Create a controller that extends `Jsapi::Controller::Base`:

```ruby
  # app/controllers/echo_controller.rb

  class EchoController < Jsapi::Controller::Base
  end
```

Define the API operation:

```ruby
  class EchoController < Jsapi::Controller::Base
    api_definitions do
      path '/echo' do
        operation :get, :echo do
          parameter 'text', type: 'string', in: 'query', default: ''
          response type: 'object' do
            property 'echo', type: 'string'
          end
        end
      end
    end
  end
```

Create the method performing the API operation:

```ruby
  class EchoController < Jsapi::Controller::Base
    api_definitions do
      # ...
    end

    def index
      api_operation :echo do |api_params|
        EchoService.new(api_params.text)
      end
    end
  end
```

Assuming that `EchoService` has a parameterless method `#echo` returning the
text passed to `::new`, an `EchoController` instance responds to

```
  GET /echo?text=Hello
```

with

```json
  {
    "echo": "Hello"
  }
```

