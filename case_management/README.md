# Groundwork Case Management (Rails Engine)

`groundwork-case_management` is a Rails engine that provides the core primitives for case intake and workflow routing:

- **Application forms** that become immutable at submission time
- **Cases** that track the current workflow step and computed facts
- **Tasks** (STI) for staff queues and due-date management
- **Event-driven workflow routing** via RailsEventStore + a lightweight workflow DSL

If you’re integrating this into a host Rails app, start with `docs/README.md`.

## Requirements

- Ruby `>= 3.2`
- Rails `>= 7.2` (host app)
- A RailsEventStore client (the engine wires a default client if the host app does not)
- Postgres is strongly recommended (UUID + JSONB columns are assumed in the default migrations)

## Installation

### Option A: From this monorepo (local path)

```ruby
# Gemfile
 gem "groundwork-case_management", path: "case_management"
```

### Option B: As a published gem

```ruby
# Gemfile
gem "groundwork-case_management", "~> 0.1"
```

Then:

```bash
bundle install
```

## Quick start (host app)

1) Install initializer + base tables:

```bash
bin/rails generate groundwork:install
bin/rails db:migrate
```

2) Generate a workflow skeleton (example):

```bash
bin/rails generate groundwork:application_form PermitApplicationForm applicant_name:name business_address:address business_ein:ein
bin/rails generate groundwork:case PermitCase
bin/rails generate groundwork:task PermitReviewTask PermitCase
bin/rails generate groundwork:workflow PermitWorkflow PermitCase
```

3) Register your workflow router (in `config/initializers/groundwork.rb`):

```ruby
PermitWorkflowRouter.register!
```

4) Emit events with `Groundwork::CaseManagement::EventBus.publish(...)` from your domain code.

## Documentation

- Guides index: `docs/README.md`

## Development (this engine)

From the repo root:

```bash
bundle exec rspec case_management/spec
```
