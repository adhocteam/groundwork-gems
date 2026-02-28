# Agent Guidance and Root Test Runner Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add root-level agent guidance for no-pager GitHub CLI usage and a root command that runs all gem specs.

**Architecture:** Create a new root `AGENTS.md` documenting `gh --no-pager` / `GH_PAGER=cat` usage to prevent pager hangs. Add an executable shell script at `bin/test-all-gems` that iterates through the five root gem directories, installs dependencies, and runs `bundle exec rspec` per gem with fail-fast behavior. Keep implementation minimal and explicit.

**Tech Stack:** Markdown, Bash, Bundler, RSpec.

---

### Task 1: Add agent guidance document

**Files:**
- Create: `AGENTS.md`
- Test: `AGENTS.md` (content checks)

**Step 1: Write the failing test**

Run:

```bash
test -f AGENTS.md
```

**Step 2: Run test to verify it fails**

Run:

```bash
test -f AGENTS.md
```

Expected: non-zero exit because file does not exist.

**Step 3: Write minimal implementation**

Create `AGENTS.md` with a concise section:
- `gh` commands must use `--no-pager`, or
- run with `GH_PAGER=cat` when `--no-pager` is unavailable.

**Step 4: Run test to verify it passes**

Run:

```bash
test -f AGENTS.md && rg -n "no-pager|GH_PAGER=cat|gh" AGENTS.md
```

Expected: zero exit with matching guidance lines.

**Step 5: Commit**

```bash
git add AGENTS.md
git commit -m "docs: add agent guidance for gh no-pager usage"
```

### Task 2: Add root test runner script

**Files:**
- Create: `bin/test-all-gems`
- Test: `bin/test-all-gems` (content + executable check)

**Step 1: Write the failing test**

Run:

```bash
test -x bin/test-all-gems
```

**Step 2: Run test to verify it fails**

Run:

```bash
test -x bin/test-all-gems
```

Expected: non-zero exit because executable script does not exist.

**Step 3: Write minimal implementation**

Create executable `bin/test-all-gems` script with:
- strict mode (`set -euo pipefail`)
- gem list: `case_management forms_core forms_rails government_attributes rules_engine`
- loop: `bundle install` then `bundle exec rspec --format progress` in each gem dir
- clear progress echo per gem

**Step 4: Run test to verify it passes**

Run:

```bash
test -x bin/test-all-gems && rg -n "case_management|forms_core|forms_rails|government_attributes|rules_engine|bundle exec rspec" bin/test-all-gems
```

Expected: zero exit and all gem names present.

**Step 5: Commit**

```bash
git add bin/test-all-gems
git commit -m "chore: add root script to run all gem specs"
```

### Task 3: Verify script execution and publish

**Files:**
- Modify: none
- Verify: `AGENTS.md`, `bin/test-all-gems`, git status

**Step 1: Write the failing test**

Run:

```bash
bin/test-all-gems
```

**Step 2: Run test to verify it fails**

Run:

```bash
bin/test-all-gems
```

Expected: may fail if local gems are missing; this captures real baseline behavior.

**Step 3: Write minimal implementation**

No additional code; use output to validate dependency setup and test execution path.

**Step 4: Run test to verify it passes**

Run:

```bash
bin/test-all-gems && git --no-pager status --short
```

Expected: script runs through all gems successfully in configured environments; git status remains clean after commits.

**Step 5: Commit**

```bash
git add -A
git commit -m "chore: finalize agent guidance and root test runner"
git push
```
