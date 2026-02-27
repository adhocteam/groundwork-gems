# Events

After reading this guide, you will know:

- How `EventBus` maps event names to RailsEventStore event classes
- What payload keys routers require
- How to choose stable, conventional event names

## EventBus

`Groundwork::CaseManagement::EventBus` is a thin wrapper around the host app’s configured RailsEventStore client:

- `publish(event_name, payload = {})`
- `subscribe(event_name, handler)`

Event names are treated as class-like constants: `"PermitPrescreeningCleared"`, `"PermitReviewComplete"`, etc.

Internally, `EventBus` dynamically creates (or resolves) a `RailsEventStore::Event` subclass under:

`Groundwork::CaseManagement::Events::<EventName>`

Routers read the event name using `event.class.name.demodulize`, so the *demodulized class name* must match the `on:` strings in your `WorkflowDefinition`.

## Payload conventions (router-compatible)

Routers select cases using `Case.for_event(payload)`, which looks for:

- `payload[:case_id]`, or
- `payload[:application_form_id]`

If you publish events that should advance a case, include one of those keys.

### Example: form submission

`Groundwork::ApplicationForm` publishes:

- event name: `"<FormClassName>Submitted"`
- payload: `{ application_form_id: <id>, submitted_at: <time> }`

### Example: task completion

When staff complete a task, publish an event that includes the `case_id`:

```ruby
Groundwork::CaseManagement::EventBus.publish(
  "PermitReviewComplete",
  case_id: kase.id
)
```

## Configuring the event store client

The engine sets `Rails.configuration.event_store` automatically if the host app does not. You can override in your app initializer:

```ruby
# config/initializers/groundwork.rb
Rails.configuration.event_store = RailsEventStore::Client.new
```

If you use RailsEventStore with ActiveRecord persistence, install RailsEventStore’s migrations in the host app as well.

