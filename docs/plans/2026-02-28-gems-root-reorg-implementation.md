# Gems Root Reorganization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Move all gems currently under `rails/` to the repository root and add a root `README.md` documenting each gem.

**Architecture:** Keep gem internals unchanged and only move top-level gem directories to root (`git mv`), then add a concise root README that links to each gem's internal README. Validate resulting structure with filesystem and git status checks.

**Tech Stack:** Git, Ruby gemspec metadata, Markdown documentation.

---

### Task 1: Move gem directories to root

**Files:**
- Modify: repository directory structure (move `rails/case_management`, `rails/forms_core`, `rails/forms_rails`, `rails/government_attributes`, `rails/rules_engine`)

**Step 1: Write the failing test**

Use a structure check command expecting root directories that do not yet exist:

```bash
test -d case_management && test -d forms_core && test -d forms_rails && test -d government_attributes && test -d rules_engine
```

**Step 2: Run test to verify it fails**

Run:

```bash
test -d case_management && test -d forms_core && test -d forms_rails && test -d government_attributes && test -d rules_engine
```

Expected: non-zero exit because directories are still under `rails/`.

**Step 3: Write minimal implementation**

Run:

```bash
git mv rails/case_management . && \
git mv rails/forms_core . && \
git mv rails/forms_rails . && \
git mv rails/government_attributes . && \
git mv rails/rules_engine .
```

**Step 4: Run test to verify it passes**

Run:

```bash
test -d case_management && test -d forms_core && test -d forms_rails && test -d government_attributes && test -d rules_engine
```

Expected: zero exit.

**Step 5: Commit**

```bash
git add -A
git commit -m "refactor: move gem directories from rails to root"
```

### Task 2: Add root README with gem information

**Files:**
- Create: `README.md`
- Read/reference: `case_management/README.md`, `forms_core/README.md` (if present), `forms_rails/README.md` (if present), `government_attributes/README.md`, `rules_engine/README.md` (if present), gemspec files for summaries

**Step 1: Write the failing test**

Run a check for missing root README:

```bash
test -f README.md
```

**Step 2: Run test to verify it fails**

Run:

```bash
test -f README.md
```

Expected: non-zero exit if README does not exist.

**Step 3: Write minimal implementation**

Create `README.md` with:
- Repository overview
- List of all five gems
- One short summary per gem
- Link to each gem directory/README

**Step 4: Run test to verify it passes**

Run:

```bash
test -f README.md && rg -n "case_management|forms_core|forms_rails|government_attributes|rules_engine" README.md
```

Expected: zero exit with all gem names present.

**Step 5: Commit**

```bash
git add README.md
git commit -m "docs: add root README for gem catalog"
```

### Task 3: Verify final state and publish

**Files:**
- Modify: none
- Verify: git index and filesystem

**Step 1: Write the failing test**

Check for unexpected missing moved directories:

```bash
test -d rails/case_management -o -d rails/forms_core -o -d rails/forms_rails -o -d rails/government_attributes -o -d rails/rules_engine
```

**Step 2: Run test to verify it fails**

Run:

```bash
test -d rails/case_management -o -d rails/forms_core -o -d rails/forms_rails -o -d rails/government_attributes -o -d rails/rules_engine
```

Expected: non-zero exit once moves are complete.

**Step 3: Write minimal implementation**

No additional implementation; run final verification commands.

**Step 4: Run test to verify it passes**

Run:

```bash
git --no-pager status --short
```

Expected: only intended moved directories and root README shown before final commit, and clean tree after commit/push.

**Step 5: Commit**

```bash
git add -A
git commit -m "chore: finalize root gem reorganization"
git push
```
