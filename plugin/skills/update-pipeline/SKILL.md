---
name: update-pipeline
description: 'The ABDM Catalogue update pipeline that keeps skills following the docs: the daily source watcher, hash diffing, the pull request bot, the human review gate, and the build that runs on merge to publish docs, recompile skills, regenerate the index and llms.txt, and bump the catalogue version. Use whenever working on the watcher or CI, when a source change needs handling, when explaining how skills stay current, or when someone proposes a retrieval-based approach to keeping skills fresh.'
---

# Update Pipeline

## Two things hide behind the word RAG

Separating them is the whole design.

**Retrieval at question time.** Someone asks a question, something searches the published docs, an answer comes back. Our own Docs MCP does this: hybrid keyword plus semantic search over the indexed Catalogue. The site search box and the support agent use the same server. No separate vector database: embeddings live inside the same SQLite snapshot the indexer builds.

**Regeneration at change time.** NHA changes a spec, and every skill that depended on it must change. This is not retrieval. It is a build. Treating it as retrieval produces skills that are confidently stale.

This skill is about the second one.

## The flow

```
Watched sources (daily)
   NHA: swagger YAMLs | GitHub specs | sandbox docs pages | manual drop folder
   Ours: abdm-v1-phase1-architecture-and-plan.md, the plan
        |
   Watcher: fetch, hash, diff against stored hash
        |
   Pull request: changed source + affected atom ids + atoms flipped to stale
        |
   Human review: accept, edit, or mark unverified
        |
   Merge to main
        |
   CI: lint atoms -> Spectral -> build the Docusaurus site (specs synced
       from catalogue/openapi) -> compile skills -> validate -> build index
       -> generate llms.txt -> bump catalogue_version -> index the catalogue
       into catalogue.db (keyword-only on PRs, no Ollama in CI; the deploy
       build embeds via the Ollama sidecar)
        |
   Publish: static site + docs-mcp image with the new snapshot | plugin
   release | Context7 refresh
```

## The watcher

Runs daily as a scheduled job. For each source: fetch, hash, compare to the stored hash.

On a change, it does three things and no more:

1. Identifies every atom whose `sources` include the changed file
2. Flips those atoms from `verified` to `stale`
3. Opens a pull request containing the source diff, the affected atom ids, and draft edits where the change is mechanical

**The watcher cannot merge.** A person does. This is not bureaucracy; a spec change that silently rewrote a verified atom would destroy the meaning of the word verified.

## Staleness is visible everywhere

A stale atom:

- Renders a banner on the site
- Causes the compiled skill to warn the agent that this step may have changed
- Appears in `/catalogue-status` as needing attention
- Is cited by the support agent with its status attached

An integrator should never be able to read a stale page without knowing it is stale, in any surface.

## Review of a watcher pull request

Three possible outcomes per affected atom:

| Outcome | When | Action |
|---|---|---|
| Accept the draft edit | The change is mechanical, for example a description reword upstream | Merge, atom returns to `unverified` unless re-run |
| Edit then accept | The change is real and needs prose work | Rewrite the affected sections, set `unverified`, queue verification |
| Mark unaffected | The changed part of the source does not touch this atom | Set back to `verified` with a note recording the review |

The third outcome is common and legitimate. A single-character change to one operation should not invalidate forty atoms.

## What CI does on merge

In order, because the order matters:

1. **Lint atoms.** Schema, sections, prose, graph, sources.
2. **Spectral.** The module OpenAPI files.
3. **Build the Docusaurus site.** Specs synced from `catalogue/openapi`, navigation generated from frontmatter, never hand-edited.
4. **Compile skills.** Selector, templates, prose pass.
5. **Validate.** Identifier diff and the rest. Build blocker on any failure.
6. **Build the index.** Because it walks everything above.
7. **Generate llms.txt and the full variant.** For agents that fetch rather than use MCP.
8. **Bump `catalogue_version` and index the catalogue into `catalogue.db`.** Keyword-only on pull requests because CI has no Ollama; the deploy build embeds via the sidecar.

Then publish: the static site plus a `docs-mcp` image built with the new snapshot, the plugin release with a git tag, and the Context7 refresh.

Docs and skills publish from the same build, so their versions can never disagree.

## Version stamping

Every skill and every page carries `catalogue_version` and the source hashes it was built from. This lets an agent say something specific and useful: your skills are from catalogue 2026.08.30, the docs are at 2026.09.02, run update.

Without this, a developer debugging with stale skills against fresh docs has no way to discover the mismatch.

## The manual drop folder

NHA publishes circulars and release notes that never reach a specification file. Someone owns dropping these into a watched folder. They are hashed and treated as sources like anything else.

This is the least automated part of the pipeline and the one most likely to rot. It needs a named owner and a review rota, not a hope.

## The plan is a source too

The architecture and execution plan is watched on the same schedule and by the same mechanism as anything NHA publishes. It is hashed, diffed, and a change to it opens a pull request like any other source change. The difference is what a change affects: an NHA change flips atoms to stale, a plan change forces a rebuild of the four skills compiled from it.

| | NHA source changes | Plan changes |
|---|---|---|
| Detected by | Fetch and hash | Hash against `manifest.json` |
| Affects | Atoms whose `sources` list the file | The skills in `manifest.json`'s `compiled_skills` |
| Gate | Atom lint and human review | `scripts/plan-check.sh`, then human review |
| Version bumped | `catalogue_version` | `plan_version` |

Both bumps are advertised the same way, so an installed agent can notice it is behind on either. Mechanism: `plan-sync`.

## When to add a new source

1. Can it change what an atom says? If no, it is reference reading, not a source.
2. Is it fetchable reproducibly? If it needs a headless browser, say so in the watcher config.
3. Who reviews changes to it?

A source with no named reviewer will generate pull requests nobody merges, and the Catalogue will drift while appearing to be watched.

## Related

- Bringing sources in the first time: `openapi-ingest`
- What gets rebuilt: `skill-compiler`, `scalar-docs`
- The checks that run: `catalogue-linting`
- Run a sweep: `/source-check`
