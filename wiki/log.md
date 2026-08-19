# Wiki Log

Append-only timeline of all wiki operations.

| Date | Operation | Subject | Notes |
|------|-----------|---------|-------|
| 2026-06-24 | init | wiki structure | Created AGENTS.md, index.md, log.md |
| 2026-06-25 | review | CATAPA-WEB repo-specific patterns | Kept null-contract and Storage visibility guidance repo-specific for CATAPA-WEB instead of global pattern. |
| 2026-06-25 | infra | hosted wiki manifest | Added machine-readable manifest so LLMs can read hosted raw markdown as source of truth. |
| 2026-08-10 | feedback | Digital Employee CATAPA API agent review lessons | Added repo-specific review patterns for platform-HITL API write tools, manifest-driven API docs generation, and DE Makefile wiring. |
| 2026-08-10 | feedback | Digital Employee CATAPA API docs generator determinism | Captured PR #1417 lesson to verify repeated `make generate-api-docs` stays clean and avoid committing live Swagger ordering/write-only `$ref` churn. |
| 2026-08-10 | feedback | Digital Employee CATAPA API agent local package wiring | Captured PR #1417 fix: DE consumers of the symlinked common CATAPA API agent need a local uv path dependency so absolute `catapa_api_agent.*` imports resolve during `make test`/CI. |
| 2026-08-11 | feedback | Digital Employee CATAPA API hosted docs lookup packaging | Updated stale generator guidance after PR #1417 moved to hosted lookup and captured setuptools cleanup needed when deleting common-agent script packages. |
| 2026-08-19 | feedback | Digital Employee CATAPA ESS/MSS multipart write contracts | Captured PR #1417 implementation lesson: ESS entry mutations require named multipart JSON parts, absence creation needs resolved `attendanceStatus` plus timezone/date fields, and write success needs read-back verification. |
