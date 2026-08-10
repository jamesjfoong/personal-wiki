---
title: Digital Employee review patterns
repo: GDP-ADMIN/digital-employee
updated: 2026-08-10
---

# Digital Employee Review Patterns

## Never Flag

- Do not require model-controlled `confirmed` booleans for CATAPA API mutations. Write safety should be enforced by separate read/write tools plus platform HITL tool configuration, not by a field the LLM can set.

## Always Flag

### CATAPA API agent write-tool safety

- trigger: `common/agents/catapa_api_agent/**`, LangChain/AIP tools that can mutate CATAPA private/public APIs
- learned_from: GDP-ADMIN/digital-employee#1372 reviewer feedback
- rule: CATAPA mutating API access must use dedicated write tools protected by platform HITL (`agent_config` + `tool_configs`) and schemas without model-controlled confirmation fields.
- avoid: Do not expose or export legacy generic tools such as `catapa_private_api_tool` / `catapa_public_api_tool` whose schema lets the model set `confirmed: bool`.
- example: `catapa_private_api_read_tool` and `catapa_private_api_write_tool` should be separate exported tools; only the write tool gets HITL config.

### CATAPA API docs manifest layout and generation

- trigger: `catapa-ess-mss/references/**`, `allowlist*.schema.json`, generated CATAPA API docs fragments
- learned_from: GDP-ADMIN/digital-employee#1372 and #1417 reviewer feedback
- rule: Endpoint allowlists should be manifest-driven `allowlist*.schema.json` files with `basePath`, `type`, `apiDocsPath`, and `allowedEndpoints`; generated API docs fragments should live under `references/api-docs/*.json` and be reproducible via `generate-api-docs.sh` or the DE Makefile target.
- avoid: Do not rely on ad-hoc `.txt` allowlists, hardcoded static source specs, stale `outputPath` fields, or raw script names like `generate_openapi_fragments.sh` in docs.
- example: `make generate-api-docs` in `common/applications/digital-employee-employee-assistant` regenerates the committed ESS/MSS API docs from manifests.

### CATAPA live Swagger nondeterministic output

- trigger: `common/agents/catapa_api_agent/scripts/extract_paths_fragment.py`, generated `references/api-docs/*.json`
- learned_from: GDP-ADMIN/digital-employee#1417 feedback implementation
- rule: After changing CATAPA API docs generation, run `make generate-api-docs` repeatedly and ensure the working tree stays clean. Live Swagger may reorder maps/`oneOf` arrays or alternate ignored write-only `$ref` siblings, so generation should compare normalized semantics before rewriting committed fragments.
- avoid: Do not commit churn-only regenerated API docs caused by live Swagger ordering or equivalent write-only `$ref` noise.
- example: The fragment writer should report `unchanged ... private-endpoint-*.json` when regenerated docs are semantically equivalent.

## Reviewer Preferences

- Prefer wiring recurring DE maintenance commands into the DE-local `Makefile` so contributors can use a one-liner instead of remembering long raw script paths.
- Keep fallback documentation out of endpoint capability skills when it could encourage agents to go beyond the committed contract. If a use case is not covered by committed reference files, the skill should say the capability is not exposed yet rather than inventing or browsing for endpoints.

## Build / Test Quirks

- The standalone `common/agents/catapa_api_agent` package may need test-only extras when run directly, for example: `uv run --with pytest --with pytest-asyncio --with 'glaip-sdk[local]' pytest tests -q`.
- For CATAPA API docs generator changes, pair common-agent checks (`uv run --with pytest --with pytest-asyncio --with ruff --with pyyaml --with 'glaip-sdk[local]' ruff check ...` plus relevant pytest files) with the consumer DE `make generate-api-docs` target and verify no generated JSON diff remains.
- When a DE consumes `common/agents/catapa_api_agent` through a tracked symlink, the consumer `pyproject.toml` still needs a local uv path dependency (`catapa-api-agent = { path = "../../agents/catapa_api_agent" }`). The common package uses absolute `catapa_api_agent.*` imports, so `make test`/CI can fail with `ModuleNotFoundError: No module named 'catapa_api_agent'` unless the local package is installed into the app environment.
