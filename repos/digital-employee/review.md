---
title: Digital Employee review patterns
repo: GDP-ADMIN/digital-employee
updated: 2026-08-11
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

### CATAPA API docs manifest layout and hosted lookup

- trigger: `catapa-ess-mss/references/**`, `allowlist*.schema.json`, hosted CATAPA API docs lookup
- learned_from: GDP-ADMIN/digital-employee#1372 and #1417 reviewer feedback
- rule: Endpoint allowlists should be manifest-driven `allowlist*.schema.json` files with `basePath`, `type`, and exact `allowedEndpoints`; hosted lookup tools fetch canonical OpenAPI documents at runtime and gate returned contracts through these allowlists.
- avoid: Do not rely on ad-hoc `.txt` allowlists, committed generated OpenAPI fragments, stale `outputPath` / `apiDocsPath` fields, hardcoded static source specs, or raw generator script names in docs.
- example: `catapa_private_api_docs_lookup_tool` / `catapa_public_api_docs_lookup_tool` perform lookup-first contract resolution; consumer skills should instruct agents to treat `ambiguous`, `not_found`, or `unavailable` as stop conditions.

### CATAPA API agent packaging after script removal

- trigger: `common/agents/catapa_api_agent/pyproject.toml`, deleting package subdirectories such as `scripts/`
- learned_from: GDP-ADMIN/digital-employee#1417 feedback implementation
- rule: When removing a package subdirectory, update `[tool.setuptools].packages` and `[tool.setuptools.package-data]` in the common package before running standalone `uv run ...` checks.
- avoid: Do not leave `catapa_api_agent.scripts` or `scripts/*` package-data entries after deleting `common/agents/catapa_api_agent/scripts`; editable builds fail with `error: package directory './scripts' does not exist`.
- example: `uv run --with pytest --with pytest-asyncio --with ruff --with pyyaml --with 'glaip-sdk[local]' ruff check .` catches stale setuptools package entries.

## Reviewer Preferences

- Prefer wiring recurring DE maintenance commands into the DE-local `Makefile` so contributors can use a one-liner instead of remembering long raw script paths.
- Keep fallback documentation out of endpoint capability skills when it could encourage agents to go beyond the committed contract. If a use case is not covered by committed reference files, the skill should say the capability is not exposed yet rather than inventing or browsing for endpoints.

## Build / Test Quirks

- The standalone `common/agents/catapa_api_agent` package may need test-only extras when run directly, for example: `uv run --with pytest --with pytest-asyncio --with 'glaip-sdk[local]' pytest tests -q`.
- For CATAPA API docs lookup or packaging changes, pair common-agent checks (`uv run --with pytest --with pytest-asyncio --with ruff --with pyyaml --with 'glaip-sdk[local]' ruff check .` plus `pytest tests -q`) with consumer DE `make lint` and `make test`.
- When a DE consumes `common/agents/catapa_api_agent` through a tracked symlink, the consumer `pyproject.toml` still needs a local uv path dependency (`catapa-api-agent = { path = "../../agents/catapa_api_agent" }`). The common package uses absolute `catapa_api_agent.*` imports, so `make test`/CI can fail with `ModuleNotFoundError: No module named 'catapa_api_agent'` unless the local package is installed into the app environment.
