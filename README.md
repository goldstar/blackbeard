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
$pirate.context(...).add_total(:like, +1)                      # increment a like
$pirate.context(...).add_total(:like, -1)                      # de-increment a like
$pirate.context(...).add_total(:revenue, +119.95)              # can also accept floats
```

### Setting Context

Most of Blackbeard's calls are done via a context.

```ruby
$pirate.context(:user_id => current_user.id, :bot => false, :cookies => app_cookie_jar)
```

To establish identity, a context must have a user_id or a cookie_jar where blackbeard will cookie a visitor with it's own uid.  As cookie_jar is optional, you can collect metrics outside a web request.  You can also increment metrics for users other than the one currently logged in.  For example, if user A refers visitor B and vistor B joins, then you can increment User A's referrals.

It gets pretty tedious for a web app to constantly set the context. To make that more paletable you can use a before filter in Rails (or your framework's equivalent) and the $pirate.set_context method.

```ruby
before_action do |controller|
  $pirate.set_context(
    :user_id => controller.current_user.id,
    :bot => controller.bot?,
    :cookies => controller.cookies)
end
```

If you `set_context` you can now make calls directly on $pirate and they will be delegate to that context.

```ruby
$pirate.add_total(:like, +1)
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

