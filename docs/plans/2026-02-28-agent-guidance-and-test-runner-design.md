# Agent Guidance and Root Test Runner Design

## Problem
We need durable agent guidance to avoid GitHub CLI pager hangs and a root-level command to run all gem test suites from one place.

## Chosen Approach
1. Create root `AGENTS.md` with GitHub CLI safety guidance:
   - Prefer `gh --no-pager ...`
   - Or set `GH_PAGER=cat` when needed
2. Add executable `bin/test-all-gems` script that:
   - Iterates through `case_management`, `forms_core`, `forms_rails`, `government_attributes`, and `rules_engine`
   - Runs `bundle install` then `bundle exec rspec` per gem
   - Fails fast on first failing gem

## Trade-offs
- Script is explicit and portable without requiring `make`.
- Running `bundle install` each time is slower but reduces missing-gem failures.
- Fail-fast behavior speeds feedback loops for CI/local fixes.

## Validation
- Confirm `AGENTS.md` exists with `gh --no-pager` guidance.
- Confirm `bin/test-all-gems` is executable and references all five gems.
- Run `bin/test-all-gems` from repo root.
