# Gems Root Reorganization Design

## Problem
All gems currently live under `rails/`, and there is no root-level README that explains the gems in this repository.

## Approved Approach
Move all five gem directories from `rails/` to repository root:

- `case_management`
- `forms_core`
- `forms_rails`
- `government_attributes`
- `rules_engine`

Then add a root `README.md` that:

1. Describes the repository purpose.
2. Lists each gem with a short summary.
3. Links to each gem's own README.

## Trade-offs Considered
- **Move + root README (chosen):** simplest navigation; aligns repo layout with gem boundaries.
- **README only:** least disruptive, but keeps nested structure that is harder to scan.
- **Partial move:** introduces inconsistency and migration ambiguity.

## Validation
- Confirm directories exist at root.
- Confirm `rails/` no longer contains those gem directories.
- Confirm root `README.md` renders links to gem READMEs.
