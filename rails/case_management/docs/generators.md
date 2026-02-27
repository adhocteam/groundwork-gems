# Generators

This engine ships Rails generators intended to bootstrap host-app code. The generated output is a starting point: you are expected to edit it.

## `groundwork:install`

```bash
bin/rails generate groundwork:install
```

Creates:

- `config/initializers/groundwork.rb`
- A migration `create_groundwork_tables` with `groundwork_workflow_transitions` and `groundwork_tasks`

## `groundwork:application_form`

```bash
bin/rails generate groundwork:application_form PermitApplicationForm applicant_name:name business_address:address
```

Creates:

- `app/application_forms/permit_application_form.rb`
- A migration `create_permit_application_forms`
- `spec/application_forms/permit_application_form_spec.rb`

Attributes with types `name`, `address`, `ein`, `tax_id`, `money`, and `memorable_date` are emitted as `gov_attribute` declarations.

## `groundwork:case`

```bash
bin/rails generate groundwork:case PermitCase
```

Creates:

- `app/cases/permit_case.rb`
- `app/state_machines/permit_case_state_machine.rb`
- A migration `create_permit_cases`
- `spec/cases/permit_case_spec.rb`

## `groundwork:task`

```bash
bin/rails generate groundwork:task PermitReviewTask PermitCase
```

Creates:

- `app/tasks/permit_review_task.rb`
- `spec/tasks/permit_review_task_spec.rb`

## `groundwork:workflow`

```bash
bin/rails generate groundwork:workflow PermitWorkflow PermitCase
```

Creates:

- `app/workflows/permit_workflow.rb`
- `app/workflows/permit_workflow_router.rb`
- `spec/workflows/permit_workflow_spec.rb`

After generation:

- Register your router in `config/initializers/groundwork.rb`
- Align your case’s Statesman machine with workflow states/transitions

