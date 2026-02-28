# Getting Started

This guide covers integrating `groundwork-case_management` into a host Rails application.

After reading this guide, you will know:

- How to install the engine and its base tables
- How to generate a case type + workflow
- How events drive workflow transitions

## 1. Add the gem

### From this repo (local path)

```ruby
gem "groundwork-case_management", path: "case_management"
```

### From RubyGems

```ruby
gem "groundwork-case_management", "~> 0.1"
```

Then:

```bash
bundle install
```

## 2. Install initializer + base tables

Run:

```bash
bin/rails generate groundwork:install
bin/rails db:migrate
```

This generates:

- `config/initializers/groundwork.rb` (configuration + router registration)
- A migration that creates:
  - `groundwork_workflow_transitions` (Statesman audit trail)
  - `groundwork_tasks` (STI tasks table)

## 3. Create your program types

Create an application form:

```bash
bin/rails generate groundwork:application_form PermitApplicationForm applicant_name:name business_address:address business_ein:ein
```

Create a case type:

```bash
bin/rails generate groundwork:case PermitCase
```

Create a staff task (optional, for staff steps):

```bash
bin/rails generate groundwork:task PermitReviewTask PermitCase
```

Create a workflow + router:

```bash
bin/rails generate groundwork:workflow PermitWorkflow PermitCase
```

## 4. Define a workflow

Edit the generated `app/workflows/permit_workflow.rb` and declare:

- Steps (`applicant_step`, `system_step`, `staff_step`, `third_party_step`)
- `on_start` step
- Event-driven transitions

The conventional “start event” is your form submission event:

- `Groundwork::ApplicationForm` publishes `"#{YourFormClassName}Submitted"` when `submit!` succeeds.

## 5. Register your router

In `config/initializers/groundwork.rb`, register router subclasses:

```ruby
PermitWorkflowRouter.register!
```

On boot, the engine subscribes registered routers to the configured RailsEventStore client.

## 6. Emit events to advance cases

Publish events with payloads that include either `case_id` or `application_form_id`:

```ruby
Groundwork::CaseManagement::EventBus.publish(
  "PermitReviewComplete",
  case_id: kase.id
)
```

That event name must match the `on:` string you declared in your `WorkflowDefinition`.

## Next steps

- Read `workflows.md` for the DSL and router behavior
- Read `events.md` for payload conventions
