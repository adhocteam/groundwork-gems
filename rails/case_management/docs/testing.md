# Testing

This guide collects practical testing patterns for host apps and engine contributors.

## Testing WorkflowDefinition

Workflow definitions are pure Ruby objects; they can be tested without database setup:

- steps are declared
- transitions resolve to expected next steps
- `to_mermaid` output includes expected nodes/edges

See `rails/case_management/spec/groundwork/workflow_definition_spec.rb` for an example.

## Testing routers

Prefer testing router behavior without coupling too tightly to RailsEventStore internals:

- Instantiate the router
- Call `router.call(event)` with a minimal event object that responds to `data` and has a class name that matches your event name

If you *do* test RailsEventStore wiring, configure an in-memory repository for speed in test:

```ruby
Rails.configuration.event_store = RailsEventStore::Client.new(
  repository: RubyEventStore::InMemoryRepository.new
)
```

## Testing tasks

Task queues are easiest to test at the model level:

- scope results (`.overdue`, `.unassigned`, `.assigned_to`)
- transactional assignment behavior (`.assign_next_to`)

