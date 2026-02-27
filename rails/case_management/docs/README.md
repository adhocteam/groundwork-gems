# Groundwork Case Management Guides

These guides are written for:

- **Host-app developers** integrating the engine
- **Engine contributors** working on internals

## Start here

- `getting_started.md` — install + first workflow end-to-end
- `concepts.md` — core domain concepts and responsibilities

## Host app guides

- `workflows.md` — workflow DSL, steps, routers, and state machines
- `events.md` — publishing/subscribing conventions and payload requirements
- `tasks.md` — staff queues, assignment, and task-driven events
- `authorization.md` — Pundit policies and integration patterns
- `database.md` — required tables, migrations, and recommended indexes
- `generators.md` — what each generator creates
- `testing.md` — test patterns for workflows and events

## Contributing

When updating behavior, keep docs and generators in sync with the public integration story. Prefer guides that are:

- Task-oriented (“How do I…?”)
- Explicit about file locations
- Honest about assumptions (DB, event store backend, auth model)

