---
title: "E2E Tenant-Agnostic Tests"
created: 2026-06-24
updated: 2026-06-24
source_count: 0
sources: []
tags: [pattern, e2e, testing, tenant]
---

# E2E Tenant-Agnostic Tests

## Rule

E2E tests must not depend on demo/seed data. Pattern:

1. Create employee / entity via API
2. Run test against created entity
3. Clean up (delete) after test

## Anti-Patterns

- Hardcoded demo employee names in test data
- Assuming specific IDs exist across tenants
- Tests that pass on demo tenant but fail on empty tenant

## OAuth

E2E OAuth must use `accounts-catapa.com`

## Related

- [[CATAPA-WEB Review Patterns]]
