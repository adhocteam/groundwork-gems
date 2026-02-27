# Tasks

After reading this guide, you will know:

- How tasks model staff work in a workflow
- How to build staff queues with the provided scopes
- How to emit task lifecycle events

## The `Groundwork::Task` base class

Tasks are stored in a single table (`groundwork_tasks`) using STI. Each task belongs to a case polymorphically.

Key fields:

- `case_type`, `case_id`
- `assignee_id`
- `status` (`pending` / `completed`)
- `due_on`, `description`, `notes`

## Recommended subclasses

The engine provides STI subclasses as naming conventions:

- `Groundwork::ApplicantTask`
- `Groundwork::StaffTask`
- `Groundwork::SystemTask`
- `Groundwork::ThirdPartyTask`

Your host app typically defines program-specific staff tasks, e.g.:

```ruby
class PermitReviewTask < Groundwork::StaffTask
end
```

## Queue scopes

`Groundwork::Task` provides queue-friendly scopes:

- `.incomplete`, `.overdue`
- `.unassigned`, `.assigned_to(user_id)`
- `.due_today`, `.due_tomorrow`, `.due_this_week`

### Transaction-safe assignment

To avoid two workers claiming the same task:

```ruby
task = Groundwork::Task.assign_next_to(current_user.id)
```

## Publishing task events

When a task’s `status` changes, the base class publishes an event:

`"<TaskClassName><Status>"` (demodulized class name + `Pending`/`Completed`)

Payload includes:

- `task_id`, `case_id`, `case_type`

If you want a workflow transition to occur on task completion, listen for the appropriate event name in your workflow definition and ensure your router can find the case (it will, because the event includes `case_id`).

