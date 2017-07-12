# Blackbeard

Blackbeard is a Redis backed metrics collection system with a Rack dashboard.

[![Circle CI](https://circleci.com/gh/goldstar/blackbeard.svg?style=svg)](https://circleci.com/gh/goldstar/blackbeard)

## Installation

Add this line to your application's Gemfile:

    gem 'blackbeard'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blackbeard

## Usage

All Blackbeard operations are done via the global `$pirate` which you should initialize early in your app.

### Rails

To configure Rails 3+ create an initializer in `config/initializers`

```ruby
require 'blackbeard'
require 'blackbeard/dashboard'

$pirate = Blackbeard.pirate do |config|
  # see configuration options below
end
```

And inside your ApplicationController:

```ruby
before_filter { |c| $pirate.set_context(c.current_user, c.request) }, :unless => robot?
after_filter{ |c| $pirate.clear_context }
```

### Sinatra

To configure Sinatra

```ruby
require 'blackbeard'
require 'blackbeard/dashboard'

class MySinatraApp < Sinatra::Base
  enable :sessions

  $pirate = Blackbead.pirate do |config|
    # see configuration options below
  end

  before do
    $pirate.set_context(current_user, self) unless robot?
  end

  after do
    $pirate.clear_context
  end

  ...
end
```

### Configuration options

```ruby
  $pirate = Blackbeard.pirate do |config|
    config.redis = Redis.new # required. Will automatically be namespaced.
    config.namespace = "Blackbeard" # optional
    config.timezone = "America/Los_Angeles" # optional
    config.guest_method = :guest? # optional method to call on user objects if they are guests or visitors
  end
```

Note that the configuration is shared by all pirates, so only create one pirate at a time.

### Mounting the dashboard

To get the rack dashboard on Rails, mount it in your `routes.rb`. Don't forget to protect it with some constraints.

```ruby
mount Blackbeard::Dashboard => '/blackbeard', :constraints => ConstraintClassYouCreate.new
```

### Setting Context

Most of Blackbeard's calls are done via a context.

In a web request, this is handled by a before filter:

```ruby
before_filter { |controller| $pirate.set_context(controller.current_user, controller) }, :unless => robot?
after_filter { |controller| $pirate.clear_context }
```

Outside of a web request--or if you want to reference a user other than the one in the current request (e..g referrals)--you set the context before each call to `$pirate`.

```ruby
$pirate.context(user).add_metric(:referral)
```

If a context does not exist, `$pirate` will silently ignore all actions. This is useful for dealing with bots.

If the user is unidentified set user to nil or false. If your app can return a Guest object for unidentified users, see the guest configuration setting.

### Collecting Metrics

In your app, have your pirate collect the important metrics.

#### Counting Unique Metrics

Unique counts are for metrics wherein a user may trigger the same metric twice, but should only be counted once.

```ruby
$pirate.add_unique(:logged_in_user)
```

#### Counting Non-Unique Metrics

Non-unique counts are for metrics wherein a user may trigger the same metric multiple times and the amounts are summed up.

```ruby
$pirate.add_total(:like, +1)                      # increment a like
$pirate.add_total(:like, -1)                      # de-increment a like
$pirate.add_total(:revenue, +119.95)              # can also accept floats
```

### Chaining Metrics

Context methods that increment metrics always return the context, so you can chain them together.

```ruby
$pirate.set_context(user)
$pirate.add_total(:like, +1).add_unique(:likers)
$pirate.context(user).add_total(:like, +1).add_unique(:likers)
```


### Defining AB Tests

AB tests are defined in your views, controller or anywhere in your app via the global $pirate.  There is no configuration necessary (but see the gotcha below).

**_Note that ab_tests are implmented, but experiments to control them is not. AB tests and experiments are in active development._**

In a view:

```erb
<%= $pirate.ab_test(:new_onboarding, :control => '/onboarding', :welcome_flow => '/welcome') %>
```

In a controller:

```ruby
@onboarding_path = $pirate.ab_test(:new_onboarding, :control => '/onboarding', :welcome_flow => '/welcome') %>
```

You can call the test multiple times with different variations:

```ruby
@button_bg_color = $pirate.ab_test(:button_color, :control => "#FFF", :black => "#000")
@button_text_color = $pirate.ab_test(:button_color, :control => "#CCC", :black => "#FFF")
```

The best things to test are the biggest things that don't fit into a hash of options:

```erb
<% if $pirate.ab_test(:join_form) == :long_version do %>
  <!-- extra field here -->
<% end %>
```

```ruby
if $pirate.ab_test(:join_form) == :long_version do
  # validate the extra fields
end
```

GOTCHA #1:  It's good to avoid elsif and case statements. Blackbeard learns about the tests and their variations dynamically. If you're not passing in your variations as a hash, but only using conditionals, you can ensure all your variations are available with:

```ruby
$pirate.test(:friend_feed).add_variations(:variation_one, :variation_two, ...)
```

Look at the dashboard to see which variations are registered.

Test do not turn on automatically. When you first deploy the test will be set to `:inactive` or `:control`, `:off`, or `:default` if any of those variations are defined.

GOTCHA #2:  If you do not define the :inactive, :control, :off or :default variations, the result will be nil. This is the desired behavior but it may be confusing.

```ruby
$pirate.ab_test(:new_onboarding, :one => 'one', :two => 'two') # is the same as the next line
$pirate.ab_test(:new_onboarding, :inactive => nil, :one => 'one', :two => 'two') # nil when test is inactive
$pirate.ab_test(:new_onboarding, :default => 'one', :two => 'two') # => 'one' when test is inactive
```

### Features

Features are very similar to AB Tests but they are only active or inactive. You can control how they are rolled out to groups and even individuals in the dashboard.

```ruby
# With the context set
if $pirate.feature_active?(:friend_feed){ ... }

# Or outside a web request
if $pirate.context(user).feature_active?(:friend_feed){ ... }
```

### Defining groups

Group definitions are part of the configuration and should be defined
in an initializer.

```ruby
$pirate = Blackbeard.pirate do |config|
  config.define_group(:admin) do |user, controller|
    user && user.admin? # true, false
  end

  config.define_group(:seo_traffic) do |user, controller|
    controller && controller.session.refer =~ /google.com/ # remember to store refer in sessions
  end

  config.define_group(:seo_traffic) do |user, controller|
    controller && controller.session.refer =~ /google.com/ # remember to store refer in sessions
  end

  config.define_group(:purchasers) do |user, controller|
    users && user.purchases.any?
  end
end
```
The user will be nil for non-logged in visitors.  The controller
will be nil if not defined by the context (e.g. outside a web context).

If your group is segmented (doesn't return true or false), include a list possible segments.

```ruby
$pirate = Blackbeard.pirate do |config|
  ...
  config.define_group(:medalist, [:bronze, :silver, :gold]) do |user, context|
    user.engagement_level # nil, :bronze, :silver, :gold
  end
end
```

If your group definition block returns an uninitialized segment, it wil
be initialized automatically.

### Defining Cohorts

Groups and cohorts in the dictionary sense are identical.  For our purposes,
cohorts are participants that experienced something at the same time.  A participant
can only be in one cohort at a time, but can switch cohorts.

This will add the current user/visitor and current timestamp to the cohort.

```ruby
  $pirate.add_to_cohort(:joined_at) # returns false if already in cohort, otherwise true
  $pirate.add_to_cohort!(:bought_at) # always returns true. If user is already in a cohort, the timestamp is updated.
  $pirate.add_to_cohort(:joined_at, user.created_at) # You can optional pass in the timestamp
```

You'll can add cohorts to metrics compare how members who joined one day against
members who joined another day.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
