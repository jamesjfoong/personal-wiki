---
title: "ngModel Store Flow"
created: 2026-06-24
updated: 2026-06-24
source_count: 0
sources: []
tags: [pattern, angular, ngmodel, state-management]
---

# ngModel Store Flow

## When NOT to Flag One-Way `[ngModel]`

Before flagging, verify ALL three exist:

1. **Form section value changes** — component dispatches `formSectionValueChanges` (or similar) action to reducer on input change
2. **Save form action** — component dispatches `saveForm` or `saveFormSection` that syncs `NgForm.value` back to store
3. **Model/reducer initialization** — model initialized with default value in reducer, null impossible

If yes → intentional and correct. Do NOT flag.

## When TO Flag

Flag `[ngModel]` ONLY when:
- Component reads from `formData` directly for submission (not `NgForm.value`)
- NO form section change mechanism exists
- Model lacks default value

## Related

- [[CATAPA-WEB Review Patterns]]
