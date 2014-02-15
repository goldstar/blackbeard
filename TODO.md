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

### Funnels - collection of metrics

hour: hash each "uid->from->to" => segment
day: hash each "segment->from->to" => count
week: hash each "segment->from->to" => count


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


$pirate.define_group(:achieve_pirate_style) do |user, context|
  $pirate.metric(:pirate_style).achieved?
end
