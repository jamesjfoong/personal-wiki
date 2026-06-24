---
title: "CATAPA-WEB Review Patterns"
created: 2026-06-24
updated: 2026-06-24
source_count: 0
sources: []
tags: [repo, catapa-web, review]
---

# CATAPA-WEB Review Patterns

## Reviewer Preferences

| Reviewer | Focus | Style |
|----------|-------|-------|
| *(populate after observing)* | | |

## Never Flag

These are intentional patterns — do not flag in review:

- **One-way `[ngModel]` with store flow** — if component dispatches `formSectionValueChanges` + `saveFormSection`, and model has default reducer value. Flow: `store → [ngModel] → input → formSectionValueChanges → reducer → store`. See [[ngmodel-store-flow]].

## Always Flag

- **Hardcoded demo employee names** in test data. Must be tenant-agnostic: create employee, test, clean up.
- **OAuth URL not `accounts-catapa.com`**
- **Playwright E2E without `.env` exported** (env vars not picked up by default)

## PR Hygiene

- Squash to 1 commit before merge
- Commit message: include `resolve` keyword for issue linkage

## Build / Test Quirks

- `npm run test -- --watch=false` or `ng test --watch=false`
- Targeted tests: run only changed file's spec before push

## Related

- [[ngmodel-store-flow]]
- [[e2e-tenant-agnostic]]
