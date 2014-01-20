# Blackbeard

Blackbeard is a Redis backed metrics collection system with a Rack dashboard.

## Installation

Add this line to your application's Gemfile:

    gem 'blackbeard'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blackbeard

## Usage

In an initializer create your global $pirate and pass in your configuration.

```ruby
require 'blackbeard'
require 'blackbeard/dashboard'

$pirate = Blackbeard.pirate do |config|
  config.redis = Redis.new # required. Will automatically be namespaced.
  config.namespace = "Blackbeard" # optional
  config.timezone = "America/Los_Angeles" # optional
end
```

Note that the configuration is shared by all pirates, so only create one pirate at a time.

To get the rack dashboard on Rails, mount it in your `routes.rb`. Don't forget to protect it with some constraints.

```ruby
mount Blackbeard::Dashboard => '/blackbeard', :constraints => ConstraintClassYouCreate.new
```

### Collecting Metrics

In your app, have your pirate collect the important metrics.

#### Counting Unique Metrics

Unique counts are for metrics wherein a user may trigger the same metric twice, but should only be counted once.

```ruby
$pirate.context(:user_id => user_id, :cookies => cookies).add_unique(:logged_in_user)
```

#### Counting Non-Unique Metrics

Non-unique counts are for metrics wherein a user may trigger the same metric multiple times and the amounts are summed up.

```ruby
$pirate.context(...).add(:like, +1)                      # increment a like
$pirate.context(...).add(:like, -1)                      # de-increment a like
$pirate.context(...).add(:revenue, +119.95)              # can also accept floats
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

