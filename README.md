# Blackbeard

Blackbeard is a Redis & Rack metric and dashboard.
Rack based
Redis
Browser managed
Server-side (in views, controllers, crons)
Browser-side (in javascript via REST hook)
Minimal configuration


Multiple experiments running simultaneously
  Each experiment supports
    Multi-goals
      * true or false (e.g. join)
      * increments (e.g. likes, revenues)
      * funnels (e.g. step 3 of 4)
      * reusable accross experiments
      * define goals in controllers, views, javascript

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
$pirate = Blackbeard.pirate do |config|
  config.namespace = "Hello"
  config.unique_indentifier = proc { |context| context.current_user_id }
  config.timezone = "America/Los_Angeles"
end
```

Note that the configuration is shared by all pirates, so only create one pirate at a time.

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

.test(...)
```

