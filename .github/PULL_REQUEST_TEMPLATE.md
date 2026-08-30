## Summary

<!-- 1–3 sentences: what this PR does and why it matters. Link the
motivating issue. Keep the prose tight — the body is reviewed under
time pressure. -->

Closes #<issue-number>

## Why

<!-- Context: what was broken, missing, or wanted, and how it was
noticed. Link any related issues, prior PRs, design docs, or
discussions that justify the approach. -->

## What changed

<!-- Concrete, file-level edits. For non-trivial changes list the
file, the line count, and one bullet per logical change. -->

`path/to/file` (+X/-Y):

- bullet 1
- bullet 2

## Implementation Checklist

<!-- Map each checkbox below to a numbered step in the plan. For
larger work the plan lives at `.omo/plans/<plan-name>.md` and the
captured evidence at `.omo/evidence/<task>-<short-desc>.diff`;
reference both at the top. For ad-hoc fixes without a plan, list
the concrete edits in place of the plan steps. Items left unchecked
stay visible for the reviewer to verify. -->

- [ ] Plan: `.omo/plans/<plan-name>.md` _(omit line if no plan)_
- [ ] Evidence: `.omo/evidence/<task>-<short-desc>.diff` _(omit line if no plan)_
- [ ] Edit 1: short description of concrete change
- [ ] Edit 2: short description
- [ ] Edit 3: short description

## Test plan

<!-- Mark completed items with [x]; leave unchecked items for the
reviewer to verify. Add distro- or scenario-specific items as
needed. -->

- [ ] `sh -n` syntax check on modified scripts (where applicable)
- [ ] `pre-commit run --files <changed files>` clean
- [ ] `docker compose run --rm dotfiles-ci-debian` — smoke test passes end-to-end
- [ ] Manual repro of the original bug / scenario
- [ ] CI: ubuntu / arch / fedora / darwin / debian via `ci-unit-test.yml`

## Out of scope

<!-- What was intentionally NOT changed in this PR, and why. -->

## Notes for review _(optional)_

<!-- Load-bearing details, invariants that must not be broken,
gotchas, anything that took longer than it should have to figure
out, hardlinks, race conditions, or assumptions about the host
environment. -->

---
