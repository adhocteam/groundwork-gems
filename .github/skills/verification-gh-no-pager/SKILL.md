---
name: verification-gh-no-pager
description: Use when running GitHub CLI verification commands so pager behavior cannot block automation or interactive sessions
---

# Verification Commands with gh --no-pager

## Rule

For verification commands that use GitHub CLI, always disable paging:
- Prefer `gh --no-pager <command>`
- Fallback: `GH_PAGER=cat gh <command>`

## Required step

Before executing any `gh` verification command, rewrite it to no-pager form.

Examples:
- `gh pr view` -> `gh --no-pager pr view`
- `gh run list` -> `gh --no-pager run list`
- `gh run view <id> --log` -> `gh --no-pager run view <id> --log`

## Do not

- Do not run raw `gh ...` verification commands without no-pager protection.
