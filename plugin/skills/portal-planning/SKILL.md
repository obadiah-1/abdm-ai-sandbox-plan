---
name: portal-planning
description: The ABDM Developer Portal schedule, workstreams, ownership split, two-day shipping increments, definition of done, and risk register. Use whenever someone asks what ships when, what is blocked, who owns a piece of work, whether V1 is on track, what counts as finished, how to sequence a task, or wants a standup, a status update, or a re-plan. Also use when scope is being added or cut so the trade is made against the schedule rather than in the abstract.
plan_version: 2026.08.24-4
plan_source: abdm-v1-phase1-architecture-and-plan.md
plan_hash: sha256:cdb2f0b61402cf7f7d4a278a16a65b77d8dc43d0bb3056ee8039124700aee0d6
compiled_from_plan: true
---

# Portal Planning

## The shape of the work

Five workstreams, two owners, two-day increments, targeting a usable V1 in the first week of September. Functional and strategic work runs about two days ahead of technical work on every stream. That lead is deliberate: the technical owner should never be blocked waiting for a decision about what a page should say.

| Stream | Produces |
|---|---|
| Catalogue | The atoms, the schema, the writing guide, the glossary |
| Site and MCP | The self-hosted Docusaurus + Scalar reference site, and the Docs MCP server and indexer |
| Skills | The compiler, the validator, the index, the plugin |
| Pipeline | The watcher, the pull request bot, CI, the publishers |
| Proof | The support agent, the eval set, the first-day developer test |

## Ownership split

The split is by kind of judgement, not by convenience.

| Stream | Functional and strategic owner | Technical owner |
|---|---|---|
| Catalogue | Atom schema decisions, writing guide, every body's five sections, dummy-proofness review, glossary | OpenAPI ingestion and cleanup, callbacks as webhooks per module file, endpoint stubs, sandbox verification runs, verified stamps |
| Site and MCP | Information architecture mirroring developer.eka.care flows, theme, landing copy, depth labels | Docusaurus and Scalar setup, spec conventions, the docs-mcp server and indexer, domains, deploys |
| Skills | Template prose, index decision tree, trigger descriptions, what each skill must refuse to guess | Compiler, validator, plugin manifest, per-agent adapters |
| Pipeline | Source inventory, review rota | Watcher, PR bot, CI, publishers |
| Proof | Recruiting the first-day developer, running the test, writing up gaps | Wiring the support agent, running the eval set, fixing |

When a question arrives, route it by asking: is this a judgement about what a developer needs to understand, or about how a system should work? The first is functional. The second is technical.

## Two-day increments

Every checkpoint ends with something an integrator can actually use. This is the rule that keeps the project from producing two weeks of scaffolding and no artefact.

| Checkpoint | An integrator can |
|---|---|
| 1 | Open the docs site with the HIE-CM OpenAPI reference rendered and searchable, plus the sandbox registration guide |
| 2 | Read dummy-proof M1 pages, run the M1 curls against sandbox, ask the Docs MCP questions |
| 3 | Install the index and the M1 skills into a coding agent and scaffold M1 |
| 4 | Read M2 and M3 at the same depth, install the full plugin, and see the phase scope stated on every landing page |
| 5 | Use the whole thing, file a gap from the support agent, watch a source change open a pull request |

When a checkpoint is at risk, cut depth, not the checkpoint. A checkpoint that slips takes the next one with it.

## Definition of done for V1

Every item is checkable. None is a judgement call. This is the list to run before anyone says the word ship.

1. Catalogue lint passes on main: schema valid, five sections present, no em dash, every `related` id resolves, every source has a hash
2. Every HIE-CM M1 to M3 endpoint atom has a curl that was run against sandbox and the response recorded in the atom
3. Every NHA functional test case for M1 to M3 exists as a test atom and is referenced by a test skill
4. All skills compile, validate and install individually; the plugin installs as one unit
5. The index skill is generated from the graph and lists every skill, agent and tool
6. Docs site live (GitHub Pages first, custom domain when ready) with search and the module references; docs-mcp deployed with its nine tools answering over the current snapshot, `/healthz` reporting the catalogue version
7. The watcher has opened at least one real pull request from a real source change
8. The support agent answered the six eval tasks from the Catalogue, citing atom ids, with the score recorded
9. The first-day developer test passes: no ABDM exposure, docs URL and sandbox credentials only, successful M1 ABHA verification call in under two hours with no human asked
10. The landing page, index entries and skill descriptions state the phase scope, HIE-CM M1 to M3 in Phase 1, M4 and UHI in Phase 2, NHCX out of scope, and every unverified atom renders the banner
11. Public repo, neutral licence, contributing, security and governance files present, no `eka.care` reference in the core Catalogue

## Risk register

Each risk carries the decision it needs, because an unowned risk is just anxiety.

| Risk | Mitigation | Decision needed |
|---|---|---|
| NHA swagger is inconsistent or incomplete, with known 403s on some V3 sandbox endpoints | Ingest, hand-correct, record both the NHA file and the correction in `sources`, mark unverified until sandbox confirms | Accept that some endpoints ship unverified |
| Docusaurus guides and Scalar references are two rendering systems on one site | Keep prose in plain markdown, avoid MDX beyond callouts and steps, so it ports anywhere; specs stay the single source under `catalogue/openapi/` | Decided: fully self-hosted from day one, no hosted-Scalar phase |
| An existing community docs site overlaps heavily | Reach out early, propose the Catalogue as shared upstream | Product makes the call and the call |
| The time available is not enough for three gateways at full depth | Phase 1 is HIE-CM M1 to M3 only. M4 and UHI are Phase 2, NHCX is out of scope | Needs sign-off, already decided in the plan |
| The prose pass invents facts | Validator diffs every identifier against the Catalogue, any new token fails the build | None, it is a hard rule |
| The Docs MCP is public with no auth in V1 | Read-only server over public docs; rate limiting at the reverse proxy; Ollama sidecar never exposed | Add auth and quotas only when abuse is observed |
| Ollama sidecar down at query time | Search degrades to keyword-only by design; `/healthz` reports `embeddings: false` | None, the degradation is tested |
| Sandbox credentials take three to four days | Apply on day one, in parallel with schema work | Apply immediately |

## Sequencing rules

- Schema before atoms. Atoms written against a schema that then changes have to be rewritten.
- Ingestion before endpoint atoms. Stubs are generated, not typed.
- M1 atoms before the compiler is finished. The compiler needs real atoms to be tested against.
- The index is generated last in every build, because it walks everything else.
- The first-day developer test happens before ship, not after, and its failures are fixed before ship.

## When scope is added

Ask three questions in order. If any answer is no, it is Phase 2.

1. Does this change what an integrator can do at a checkpoint?
2. Can it be built from atoms that already exist or are already scheduled?
3. Does it survive the definition of done without weakening any existing item?

## Related

- Why the structure is what it is: `portal-architecture`
- What counts as evidence of working: `portal-proof`
- The standup format: `/standup`
