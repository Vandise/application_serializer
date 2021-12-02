# ApplicationSerializer

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

This helper function must return a hash with a `context` attribute, `scope` is optional. The `context` attribute will trigger the appropriate context block defined in your Serializer. If the context is not defined, it defaults to the `default` context.

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
    { context: params[:context] || params[:action], scope: current_user }
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

#### context name\<symbol\>, block\<user\_defined\_scope, serializer\>

The context block expects an array of symbols to be returned, containing attribute names, model associations, or serializer methods. Any other return types will be ignored. See <a href="https://github.com/rails-api/active_model_serializers" target="_blank">ActiveModelSerializers</a> for implementation details.

```ruby
# app/serializers/person_serializer.rb
class PersonSerializer < ApplicationSerializer::Base
  attributes :id # always include the id field with every serialization request

  context :default do |scope, serializer|
    [:name, :catch_phrase]
  end

  context :index do
    [:name]
  end

  # Example:
  # return a hash containing a key => object.id, value => object.name to populate a select list
  context :list do
    serializer.attribute :id, key: :key
    serializer.attribute :name, key: :value
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Vandise/application_serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ApplicationSerializer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Vandise/application_serializer/blob/master/CODE_OF_CONDUCT.md).
