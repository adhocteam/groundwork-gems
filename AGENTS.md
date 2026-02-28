Legend (from RFC2119): !=MUST, ~=SHOULD, ≉=SHOULD NOT, ⊗=MUST NOT, ?=MAY.

## Working principles

**Do**
- !: Trunk-based development best practices
- !: Implement small, well scoped changes that follow existing conventions for a single task at a time.
- !: Keep all tests and policy checks green. Test prior to PR
- !: Maintain quality and automation and ADR discipline.
- ~: Create simple, maintainable designs over clever abstractions.
- ~: Follow TDD.
- !: Atomic commits as you go, following conventional commit format
- !: After finishing work (all todos done, create pr), review session and propose recommended improvements to AGENTS.md, custom agents, and skills.
- !: Push after every committed change unless user explicitly says otherwise.
- !: Include the commit hash in handoff after each push.
- !: Open a PR when working on feature branches. If working directly on `main`, push and skip PR creation unless explicitly requested.

**Do Not**

- ⊗: introduce secrets, tokens, credentials, or private keys in any form.
- ⊗: Redesign the architecture without explicit instruction or approval
- ⊗: Introduce new tools or services without explicit instruction or approval
- ⊗: Make large sweeping changes across many apps or modules without explicit approval

## Plan Execution Preflight

Before running a multi-step implementation plan, confirm you are in the correct directory/worktree/branch for the target files.

1. `git branch --show-current`
2. `pwd`
3. Check required paths using `rg` 
4. If required paths are missing, switch worktrees (`wt list`, then `wt switch <name>`) before editing.

## GitHub CLI Safety

- !: Prefer `gh pr create --body-file <file>` or `gh pr create --body-file - <<'EOF' ... EOF` instead of inline `--body` when content includes backticks or shell-sensitive characters.
- ~: Use single-quoted heredocs (`<<'EOF'`) for PR bodies to avoid accidental command interpolation.