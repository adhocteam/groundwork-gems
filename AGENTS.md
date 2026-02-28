# Agent Guidance

## GitHub CLI safety

Use `gh --no-pager` for GitHub CLI commands to avoid pager hangs.  
If `--no-pager` is unavailable, run commands with `GH_PAGER=cat`.

For verification commands that query status/results, always prefer:
- `gh --no-pager pr view ...`
- `gh --no-pager run view ...`
- `gh --no-pager run list ...`

## Local Ruby sanity check

Run this quick check before installing gems or running specs:

```bash
which ruby
ruby -v
which bundle
bundle -v
ruby -e 'require "date"; puts Date.today'
bundle env | rg -n "Ruby|RubyGems|Gem Home|Gem Path"
```

If `require "date"` fails or Ruby/Bundler paths disagree, fix your local Ruby manager setup before running `bin/test-all-gems`.
