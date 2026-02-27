# Concepts

This engine is deliberately small: it provides primitives and expects the host app to define program-specific types.

## Application forms

`Groundwork::ApplicationForm` is an abstract base model for intake forms.

Key behaviors:

- Forms are mutable in `draft` status.
- `submit!` validates with the `:submit` context, sets `submitted_at`, transitions to `submitted`, and then becomes immutable.
- After submission, a `"<FormClassName>Submitted"` event is published through `Groundwork::CaseManagement::EventBus`.

Your host app defines subclasses (one per program), e.g. `PermitApplicationForm`.

## Cases

`Groundwork::Case` is an abstract base model representing a workflow instance created from (or associated to) an application form.

It tracks:

- `application_form_id` (stored as a string to keep the reference loose)
- `current_step` (the workflow step name)
- `facts` (JSON bag for computed outputs)
- `status` (`open` / `closed`)

Your host app defines subclasses, e.g. `PermitCase`.

## Workflow transitions (audit trail)

`Groundwork::WorkflowTransition` is a shared table (polymorphic by `case_id` / `case_type`) used by Statesman to persist a full transition history, including metadata (event name, actor, notes).

## Tasks (staff queues)

`Groundwork::Task` is a concrete STI model, with recommended subclasses:

- `Groundwork::ApplicantTask`
- `Groundwork::StaffTask`
- `Groundwork::SystemTask`
- `Groundwork::ThirdPartyTask`

The base class provides queue-friendly scopes (due today/tomorrow/overdue, unassigned, assigned_to) and a transaction-safe `assign_next_to`.

## Workflows

A workflow has two parts:

1) A `Groundwork::CaseManagement::WorkflowDefinition` constant that declares steps + transitions.
2) A `Groundwork::CaseManagement::WorkflowRouter` subclass that subscribes to events and advances cases.

See `workflows.md` for the full details.

