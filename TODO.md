## TODO:

    Multi-tests
      * define test variants in multiple places
      * allow for undefined (e.g. control) variations
      * true multivariate tests with multiple AB tests
      * reusable across experiments
      * define goals in controllers, views, javascript
    Segmentation
      * true or false (e.g. premium members)
      * groupings (e.g. organization size)
      * experiment results viewable segmentation
      * reusable across experiments
      * define goals in controllers, views, javascript
    Targetting
      * by defined segments (e.g. staff?)
      * by user_id (e.g. rollout like)


Create and manage multiple experiments in a browser/rack dashboard

### Experiments

```ruby
$pirate.experiment(
  "name of test",
  :description => "Optional",
  :running => true,
  :tests => [:link],
  :goals => [:join, :like]
)
```

### Funnel Metrics

```ruby
$pirate.funnel(:checkout, 'Confirm')          # User reached step 3 of funnel (Confirm)
```

### Segments

```ruby
$pirate.segment(:premium_member) do
  current_user.premium_member?  # true or false
end

$pirate.segment(:organization_size) do
  current_user.organization_size # '0-5', '6-14', '15+'
end
```

### Changes

```ruby
$pirate.change(:link, :control => 'blue', :red => 'red')
$pirate.change(:link,
  :control => nil, # noop
  :red => Proc.new("red")
)


$pirate.variation(:link, :control) do
  something.blue
end

$pirate.variation(:link, :red) do
  ...
end
```

### Outside a Web Session

You can run them in crons or asynchronously.

```ruby
$pirate.context().goal(...)
$pirate.context()
