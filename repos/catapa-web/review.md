---
title: "CATAPA-WEB Review Patterns"
created: 2026-06-24
updated: 2026-06-25
source_count: 1
sources: ["GDP-ADMIN/CATAPA-WEB#12338"]
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
- **BatchStorage current user** (`GDP-ADMIN/CATAPA-WEB#12338`) — do not flag missing null guard for `authentication.currentUser`; reviewer/Felix confirmed current user is guaranteed non-null in this context. Keep consistent with `GDP-ADMIN/CATAPA-WEB-LIB#514`: do not ask for impossible-null guards.
- **Storage protected methods** (`GDP-ADMIN/CATAPA-WEB#12338`) — do not flag `serialize` / `unserialize` as public bypass paths. Felix confirmed they are `protected` on abstract `Storage`; public API is only `set`, `get`, `delete`, `hasKey`, `clear`, all overridden by `BatchStorage`.

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
