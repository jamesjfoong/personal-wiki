# Personal LLM Wiki — Agent Instructions

Pattern: Andrej Karpathy's LLM Wiki
Human: curates sources, directs analysis, asks questions
Agent: writes and maintains all wiki pages, cross-references, bookkeeping

---

## Architecture

```
~/wiki/
├── raw/              # immutable source documents (articles, papers, notes, images)
├── wiki/             # LLM-generated markdown pages
│   ├── index.md      # catalog of all pages (read first on query)
│   └── log.md        # append-only chronological record
└── schema/
    └── AGENTS.md     # this file
```

- raw/ — human drops sources here. Agent reads, never modifies.
- wiki/ — agent owns this entirely. Summaries, entities, concepts, comparisons, synthesis.
- schema/ — configuration. Co-evolved by human and agent over time.

## Page Types (agent decides per page)

| Type | Purpose |
|------|---------|
| Summary | Distilled source, key takeaways |
| Entity | Person, company, tool, framework |
| Concept | Abstract idea, pattern, theory |
| Comparison | Side-by-side of two+ things |
| Synthesis | Cross-source analysis, evolving thesis |
| How-To | Step-by-step process |
| Overview | High-level map of a topic area |

No rigid filename suffixes. Agent names pages for clarity.

## Frontmatter

Every wiki page should have YAML frontmatter:

```yaml
---
title: "Page Title"
created: YYYY-MM-DD
updated: YYYY-MM-DD
source_count: N        # number of raw sources backing this page
sources: [raw/file.md] # back-links to raw sources
tags: [tag1, tag2]
---
```

Use wikilinks `[[Page Name]]` for cross-references.

---

## Operations

### Ingest

Trigger: human drops source into raw/ and says "ingest this"

Flow:
1. Read the raw source
2. Discuss key takeaways with human (stay involved, check understanding)
3. Write a summary page in wiki/
4. Update entity pages (create if new, revise if existing)
5. Update concept pages (create if new, revise if existing)
6. Update comparisons if source changes prior understanding
7. Note contradictions between new source and existing wiki claims
8. Update wiki/index.md with new/updated pages
9. Append entry to wiki/log.md

A single source may touch 10-15 wiki pages. Agent must not skip updates.

### Query

Trigger: human asks a question about the wiki

Flow:
1. Read wiki/index.md first to find relevant pages
2. Read relevant wiki pages
3. Synthesize answer with citations to wiki pages
4. If answer is substantial, file it back into wiki/ as a new page (comparison, analysis, synthesis, etc.)
5. Update wiki/index.md if new page created
6. Append entry to wiki/log.md

Good answers compound — they become new wiki pages, not chat history dust.

### Lint

Trigger: human says "lint the wiki" (or runs periodically)

Checks:
1. Contradictions between pages
2. Stale claims superseded by newer sources
3. Orphan pages with no inbound links
4. Important concepts mentioned but lacking their own page
5. Missing cross-references
6. Data gaps that could be filled with web search

Report findings. Suggest fixes. Apply fixes after human confirmation or if routine.

---

## Special Files

### wiki/index.md

Content-oriented catalog. Each page listed with:
- Link to page
- One-line summary
- Metadata: created date, source count, tags

Organized by category (entities, concepts, sources, synthesis, etc.).
Updated on every ingest. Read first on every query.

### wiki/log.md

Append-only chronological record. Each entry prefixed:

```
## [YYYY-MM-DD] ingest | Article Title
## [YYYY-MM-DD] query | Question asked
## [YYYY-MM-DD] lint | Wiki health check
```

Parseable: `grep "^## \\[" wiki/log.md | tail -5` gives last 5 operations.
Never edit past entries.

---

## Rules

- Never delete or modify raw/ files
- Prefer updating existing page over creating duplicate
- Every wiki page must be reachable from wiki/index.md
- Append-only log — never edit past entries
- Use wikilinks `[[Page Name]]` for cross-references
- Cite sources in answers: "(per [[Source Page]])"
- Contradictions must be flagged, not silently overwritten
- Agent handles all bookkeeping; human curates and directs

## Git

This is a git repo. Commit after every operation:
- Ingest: commit with source title
- Query (new page): commit with question summary
- Lint: commit with "lint: fixes applied" or "lint: N issues found"

---

## Tips

- Obsidian graph view shows wiki shape — connections, hubs, orphans
- Dataview plugin queries frontmatter for dynamic tables
- Marp for slide decks from wiki content
- Images in raw/assets/, downloaded locally (not hotlinked)
- At small scale (~100 sources, ~hundreds of pages), index.md is enough search
- At larger scale, consider qmd or similar local search engine
