---
name: portal-architecture
description: 'The architecture of the ABDM Developer Portal: the four building blocks, how the Catalogue compiles into docs, skills and MCP surfaces, the seven binding principles, the atom model, and what is deliberately excluded from V1. Use whenever someone asks how the portal fits together, why a design decision was made, whether something belongs in V1, where a new capability should live, or proposes a change to the structure. Also use before designing any new component so it lands in the right layer instead of beside it.'
plan_version: 2026.08.24-4
plan_source: abdm-v1-phase1-architecture-and-plan.md
plan_hash: sha256:cdb2f0b61402cf7f7d4a278a16a65b77d8dc43d0bb3056ee8039124700aee0d6
compiled_from_plan: true
---

# Portal Architecture

## The one-paragraph version

One knowledge Catalogue of India's health gateways, scoped in phases: HIE-CM M1 to M3 in Phase 1, HIE-CM M4 and UHI in Phase 2, NHCX out of scope. It is written so a first-day developer can follow it and structured so a machine can compile it. A self-hosted Docusaurus site with Scalar's open source reference component renders the human side; our own Go MCP server with hybrid retrieval serves the machine side. A build pipeline compiles the same Catalogue into agent skills, a plugin, an index and the MCP's snapshot, and re-runs whenever NHA changes something. Everything is FOSS, self-hosted, and runs without Eka.

## The four building blocks

One is the source. Three are renderings of it.

```
01 Catalogue (source of truth)
   typed atoms + HIE-CM OpenAPI, one file per module
   callbacks as OpenAPI 3.1 webhooks inside the module file
        |
        +--> 04 Docs site         -> Docusaurus + self-hosted Scalar references
        +--> 02 Docs MCP server   -> coding agents, internal support agent
        +--> 03 Skills + plugin   -> coding agent in the integrator's repo
                + generated index
```

NHA sources are watched daily and feed the Catalogue through a reviewed pull request. Nothing feeds the renderings directly.

| Block | What it is in V1 | The rule that keeps it honest |
|---|---|---|
| 01 Catalogue | NHA's HIE-CM M1 to M3 endpoints as atoms | Nothing downstream is hand-maintained. CI fails if a skill names an endpoint or error the Catalogue lacks. |
| 02 MCP | Our own Go Docs MCP server: nine read tools over one indexed snapshot of the Catalogue, hybrid keyword plus semantic retrieval | Retrieval only. Nothing executes against NHA. Every response carries catalogue version and verification status. |
| 03 Skills | Compiled, never written. Index, per-milestone build, test and debug skills, one bundle | The compiler may reword. It may not add facts. |
| 04 Docs | Docusaurus site with self-hosted Scalar API references, structured after developer.eka.care flow pages | Stale atoms render a banner. Unverified ones say so. |

## The seven principles and their enforcement

A principle without an enforcement mechanism is a wish. Each of these has one.

| # | Principle | Enforced by |
|---|---|---|
| P1 | Scope is phased and declared, never implied: HIE-CM M1 to M3 now, M4 and UHI in Phase 2, NHCX out of scope | Mandatory `gateway` field. The index skill refuses to build if a Phase 1 milestone has zero verified atoms, and lint rejects any atom with `gateway: nhcx`. |
| P2 | Documentation is the knowledge base that powers everything | Skills, llms.txt, MCP resources and the support agent are build outputs. CI fails on any identifier not in the Catalogue. |
| P3 | No em dashes, write like a person | A CI rule blocks U+2014. The writing guide is in the repo and in the compiler prompt. |
| P4 | Human and machine readable from one source | Typed atoms: frontmatter is the machine half, body is the human half, structured blocks are fenced with a declared schema. |
| P5 | Fool, idiot and dummy proof | Five mandatory sections per atom or CI rejects it. The first-day developer test is in the definition of done. |
| P6 | FOSS, replicable, no Eka dependency, no vendor cloud | Catalogue in a public git repo under a neutral licence, copyright NHA. Everything self-hosted from day one: Docusaurus with the MIT Scalar packages vendored, no CDN, no Scalar cloud services, telemetry off, our own Go MCP server, embeddings from a self-hosted Ollama sidecar. The handover unit is one compose file. No `eka.care` URL anywhere in the core Catalogue. Eka content lives in a separate overlay repo. |
| P7 | Update once, everything moves | Source watcher opens a pull request. Merge triggers docs publish, skill recompile, plugin version bump. |

When someone proposes something that breaks a principle, name the principle and the enforcement, not just the objection.

## The atom model

An atom is one markdown file. Frontmatter is the machine half. The body is the human half with five mandatory sections. Structured facts inside the body live in fenced blocks with a declared schema so the compiler lifts them without parsing prose.

The `related` map is what turns a folder of files into a graph. The index skill is generated by walking it. The support agent cites nodes from it. Ten types exist: concept, flow, endpoint, callback, error, test, decision, glossary, fhir, sandbox.

Full schema and section rules: `atom-authoring`.

## Atom lifecycle

```
draft -> unverified -> verified -> stale -> unverified or back to verified
```

- `draft` a stub, generated from OpenAPI or hand-created
- `unverified` five sections written, lint passes, not yet run against anything
- `verified` run against sandbox, response recorded in the atom, a reviewer stamped it
- `stale` the watcher saw the source hash change

Stale renders a banner on the site and makes the compiled skill warn the agent. Unverified renders a label and the support agent says so when citing. A source change never silently edits a verified atom.

## Where new things go

Use this when someone proposes a capability and you need to place it.

| The proposal | Where it belongs |
|---|---|
| New knowledge about a gateway | An atom. Always an atom first. |
| A new way to explain existing knowledge | An atom body edit, or a skill template change. Never a new parallel document. |
| A new agent capability | A skill compiled from atoms, registered in the index. |
| A deterministic repeated operation | A script under `skills/*/scripts/`, registered in the index. |
| Something that calls NHA at runtime | Search-mode value is covered by `get_operation` and `validate_request` on the Docs MCP. Execute mode is a Phase 2 concern with its own per-caller credentials. |
| Anything Eka-specific | The overlay repo. Not the core Catalogue. See `dpg-governance`. |
| Conformance evidence, ledger, gate, simulators | Phase 2. They depend on this Catalogue existing first. |

## Gateway scope and phasing in V1

Scope is phased rather than thinned. Phase 1 is HIE-CM M1 to M3, dummy proof. HIE-CM M4 and UHI are Phase 2 and nothing is written for them in V1. NHCX is out of scope, which is not the same as deferred: no NHCX atom is written and no NHCX skill ships. The landing page, the index skill and the frontmatter all carry the phase.

One gateway at three milestones, fully proven, beats three gateways half-written. Reference-depth pages for gateways nobody is integrating this quarter cost the review time M1 to M3 needs. A confident wrong page is harmful; a page that does not exist is merely absent, and the index says so out loud. Repeat that whenever someone suggests slipping UHI or NHCX back in "since the schema supports it".

## Explicitly not in V1

Naming these prevents scope creep by accretion.

- HIE-CM M4 and UHI. Phase 2, not V1
- NHCX, entirely. Out of scope rather than deferred, and lint enforces it
- The conformance harness, ledger, gate and simulators
- Execute-mode MCP exposed publicly
- Any Eka-specific overlay content in the core Catalogue
- Multi-agent orchestration. The index routes, a single agent executes.
- Generated SDKs

If someone wants one of these, the answer is not no, it is Phase 2, because each depends on a Catalogue that does not exist yet. NHCX is the exception: the answer there is no, and it is a scope decision rather than a sequencing one.

## Related

- Schedule, ownership and done: `portal-planning`
- The licence and dependency constraint: `dpg-governance`
- Writing atoms: `atom-authoring`
- Compiling them: `skill-compiler`
