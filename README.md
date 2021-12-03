# ApplicationSerializer

[![Application Serializer Test Suite](https://github.com/Vandise/application_serializer/actions/workflows/test_suite.yml/badge.svg)](https://github.com/Vandise/application_serializer/actions/workflows/test_suite.yml)

ApplicationSerializer provides contextual serialization for ActiveModels. It preserves the original interface of <a href="https://github.com/rails-api/active_model_serializers" target="_blank">ActiveModelSerializers</a>, allowing flexibility with existing Serializers without polluting controllers with Adapter settings.

## Requirements

- active\_model\_serializers (>= 0.10.12)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'application_serializer'
```

And then execute:

  $ bundle

## Usage

ApplicationSerializer is intended for existing Rails APIs that need contextual rendering of models. The goal is to centralize changes to the Serializers.

### Rails Configuration

Autoload your Serializers directory.

```ruby
# config/application.rb
module ApiDemo
  class Application < Rails::Application
    # omitted
    config.autoload_paths << Rails.root.join('serializers')
  end
end
```

### Defining the Context and Scope

The scope passed to the Serializer (accessible by the `scope` argument in the block) is defined in your controllers. This can be any object or value returned by the `serialization_scope` helper.

This helper function must return a scope as a hash with the key `context` or an object that responds to a `context` method. The `context` attribute/method will trigger the appropriate context block defined in your Serializer. If the context is not defined, it defaults to the `default` context.

```ruby
# app/controllers/people_controller.rb

class PersonController < ApplicationController
  serialization_scope :serialization_context

  ##
  # this will trigger the context :index block if the ?context parameter is not present
  # to trigger the context :list block, make a network call containing ?context=list
  ##
  def index
    # logic omitted for brevity
    render json: Person.all
  end

  # this will trigger the context :default block
  def show
    # logic omitted for brevity
    render json: Person.where(id: params[:id])
  end

  private

  ##
  # allow a ?context=value flag, fall back on the controller action
  ##
  def set_serialization_scope
    { context: params[:context] || params[:action], user: current_user }
  end
end
```

### Update Your Serializers

An existing Serializer for a "Person" model would be defined like so:

```ruby
# app/serializers/person_serializer.rb
class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :catch_phrase
end
```

Using ApplicationSerializer, your new Serializer can inherit from `ApplicationSerializer::Base` without impacting any of the existing functionality.

```ruby
# app/serializers/person_serializer.rb
class PersonSerializer < ApplicationSerializer::Base
  attributes :id, :name, :catch_phrase
end
```

As defined, all contexts will **ALWAYS** include the **id**, **name**, and **catch_phrase** attributes of the model you're serializing. If you want to limit attributes based on scope, you must use the `context` block.

#### context(name\<symbol\> &block\<serializer, user\_defined\_scope, model\>)

The context block accepts a context name symbol and a block with 3 arguments: the serializer (to set attributes), the scope, and the model being serialized. See <a href="https://github.com/rails-api/active_model_serializers" target="_blank">ActiveModelSerializers</a> for implementation details.

```ruby
# app/serializers/person_serializer.rb
class PersonSerializer < ApplicationSerializer::Base
  attributes :id # always include the id field with every serialization request

  context :default do |serialize|
    serialize.attributes :name, :catch_phrase
  end

  context :index do |serialize|
    serialize.attributes :name
  end

  # Example:
  # return a hash containing a key => object.id, value => object.name to populate a select list
  context :list do |serialize,scope|
    serialize.attribute :id, key: :key
    serialize.attribute :name, key: :value
  end
end
```

## Testing

Serializers serving different contexts should always have supporting unit tests. The context and scope parameters are passed through the constructor of the serializer.

```ruby
require 'minitest/autorun'

class TestPersonSerializer < MiniTest::Unit::TestCase
  def setup
    @model_attributes = {id: 1, name: 'Bender', catch_phrase: 'Bender is great'}
    @person = Person.new(@model_attributes)
  end

  def test_default_context
    json_string = PersonSerializer.new(@person, scope: { context: :default }).to_json
    assert_equal ({id: @model_attributes[:id]}.to_json), json_string
  end

  def test_list_context
    json_string = PersonSerializer.new(@person, scope: { context: :list }).to_json
    assert_equal ({value: @model_attributes[:id], key: @model_attributes[:name]}.to_json), json_string
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Vandise/application_serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ApplicationSerializer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Vandise/application_serializer/blob/master/CODE_OF_CONDUCT.md).
