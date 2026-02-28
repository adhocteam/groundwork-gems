# Database

This guide covers the tables the engine expects and the tables your host app owns.

## Engine-owned base tables (installed into the host app)

The engine expects two shared tables to exist in the host application database:

1) `groundwork_workflow_transitions`
- Used by Statesman to persist workflow state transitions (audit trail)
- Polymorphic reference: `case_type`, `case_id`
- Metadata stored in `metadata` (JSON)

2) `groundwork_tasks`
- STI tasks table, polymorphic to case

Install via:

```bash
bin/rails generate groundwork:install
bin/rails db:migrate
```

## Host-owned tables (per program)

Your host app defines:

- An application form table per program (e.g. `permit_application_forms`)
- A case table per program (e.g. `permit_cases`)

Generate via:

```bash
bin/rails generate groundwork:application_form PermitApplicationForm ...
bin/rails generate groundwork:case PermitCase
```

## UUIDs + JSONB

The default generators assume:

- UUID primary keys for program tables
- JSONB for `facts` (cases) and transition metadata

If you use a different database or key strategy, adjust the generated migrations accordingly.

