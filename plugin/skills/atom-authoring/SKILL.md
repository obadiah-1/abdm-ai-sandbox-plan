---
name: atom-authoring
description: 'How to write one atom for the ABDM Catalogue: the mandatory frontmatter schema, the ten atom types, the five dummy-proof body sections, structured fenced blocks, and the related graph. Use whenever creating or editing a unit of Catalogue knowledge, whether it is a concept, flow, endpoint, callback, error, test, decision, glossary, FHIR or sandbox page. Also use when someone asks how to document an NHA endpoint, what fields a page needs, how to link pages together, or why an atom failed schema lint.'
---

# Atom Authoring

An atom is one markdown file. The frontmatter is the machine half. The body is the human half. Both come from the same file, which is the only reason the docs and the skills cannot drift.

## Before you write anything

Answer these four. If you cannot, you are not ready to write the atom.

1. **What type is it?** One of: concept, flow, endpoint, callback, error, test, decision, glossary, fhir, sandbox. If it feels like two types, it is two atoms.
2. **What is the source?** A URL and a hash. Never write an atom without a source. If the only source is a person's memory, mark it `docs-only` and `unverified`.
3. **What does the reader already have?** That becomes "Before you start" and it must link to the atoms that get them there.
4. **How will the reader know it worked?** If you cannot state an observable outcome, the atom is not finished and probably should not be merged.

## The frontmatter schema

Every field below is mandatory unless marked optional. Lint rejects anything missing.

```yaml
id: hiecm.flow.m2-link-care-context
type: flow
gateway: hiecm
milestone: M2
version: abdm-v3
title: Link a care context to a patient's ABHA
summary: >
  Tell ABDM that this patient had a visit at your facility so their records
  can be found later.
sources:
  - url: https://sandbox.abdm.gov.in/swagger/ndhm-hip.yaml
    fetched: 2026-08-24
    hash: sha256:...
verified:
  status: verified
  against: sandbox
  on: 2026-08-25
  by: shyamjith
related:
  endpoints: [hiecm.endpoint.links-link-add-contexts]
  callbacks: [hiecm.callback.on-add-contexts]
  errors: [hiecm.error.abdm-1035, hiecm.error.abdm-1037]
  tests: [hiecm.test.m2-tc-03]
  concepts: [hiecm.concept.care-context]
skills:
  - hiecm-m2-build
  - hiecm-m2-test
```

Field rules that catch people out:

- `id` is `gateway.type.slug`, lowercase, stable, and never reused. Renaming an id is a breaking change and needs a redirect.
- `gateway` is one of `hiecm`, `uhi`, `shared`. Shared atoms have no milestone; use `n/a`. There is no `nhcx` value: NHCX is out of scope and lint rejects it. `uhi` exists for Phase 2 and nothing is written against it yet.
- `version` is the NHA spec version this is true for, not the Catalogue version. The Catalogue version is stamped by the build.
- `summary` is one sentence a new developer understands with no acronyms. It is what the index and the search result show. Write it last, after the body, when you know what the atom actually says.
- `verified.status` is `verified`, `unverified` or `stale`. Only `atom-verifier` or a human who ran it may set `verified`. Writing `verified` without a recorded response is the single worst thing you can do in this repo.
- `related` ids must all resolve. Lint fails on a dangling id.
- `skills` declares which compiled skills consume this atom. The compiler reads it. An atom with no `skills` entry renders in the docs but never reaches an agent, which is sometimes correct (glossary, decision) and sometimes a mistake.

Optional fields:

- `fix.deterministic: true` on an error atom that has exactly one known fix. The compiler emits it as a direct action and the skill skips the Decide phase. Use it only when there is genuinely no judgement involved.
- `depth: reference` on a Phase 2 atom that carries sections 1 to 3 only. Nothing in Phase 1 may use it: an HIE-CM M1 to M3 atom is dummy proof or it is not done.

## The five body sections

All five headings are required, in this order, on every atom. The compiler checks presence. A reviewer checks honesty.

### 1. In plain words

What this is, for someone who has never heard of ABDM. No acronym without a glossary link on first use. If the first sentence needs a second sentence to explain a word in it, rewrite the first sentence.

### 2. Before you start

What must already be true. Credentials, registrations, a previous step, a facility that is onboarded. Every item links to the atom that gets the reader there. A bare list of nouns is a failure; each line should be checkable.

### 3. What happens

The sequence, naming who calls whom. Flows get a mermaid sequence diagram. Endpoints get a working curl with every placeholder named in the form `<YOUR_CLIENT_ID>` so it is obvious what to substitute. Never abbreviate a header away.

### 4. How you know it worked

The exact response, callback or state change to look for. Not "success". Write it as an observation:

> You receive a callback at `/on-add-contexts` with `status: SUCCESS` within 60 seconds. The `requestId` matches the one you sent.

This section is not decoration. It becomes the exit condition of every compiled skill's OODA loop. A vague section 4 produces a skill that never knows when to stop.

### 5. When it goes wrong

The three to five most common failures. Each links to an error atom that names the fix. Order by frequency, not by severity. If you know of a failure with no error atom yet, create the error atom rather than describing the fix inline.

## Structured blocks inside the body

Facts the compiler needs go in fenced blocks with a declared schema, so it lifts them without parsing prose. Prose around them stays human.

````
```observation schema=exit-condition
channel: callback
path: /on-add-contexts
match:
  status: SUCCESS
timeout_seconds: 60
```
````

Declared block schemas: `exit-condition`, `precondition`, `request`, `response`, `state-transition`. Anything else fails lint.

## Type-specific rules

Read the file for the type you are writing: `references/atom-types.md`.

## Common mistakes

| Mistake | Why it fails | Do instead |
|---|---|---|
| Two flows in one atom | The graph cannot link to half a file | Split, link with `related` |
| Section 4 says "you get a 200" | 200 means the request was accepted, not that the work happened | Name the callback and its payload |
| Curl with `-H "Authorization: Bearer TOKEN"` | The reader does not know where TOKEN came from | `<ACCESS_TOKEN_FROM_SESSIONS_CALL>` and link the atom |
| `verified: true` because it looked right | Fabricated verification is worse than none | `unverified`, and say so in the prose |
| Fix described inline in section 5 | Skills compile error atoms separately | Create the error atom, link it |
| Em dash anywhere | CI blocks U+2014 | Full stop, comma or colon |

## How the indexer reads your atom

The Docs MCP indexer walks the catalogue and parses every `.md` outside
`openapi/` as an atom, with one exception, the `README.md` at the
catalogue root. A file that fails to parse fails the whole build,
loudly, naming the file. Atom bodies are chunked per `##` heading and
embedded for semantic search. The full walk contract, including what
feeds which MCP tool, is documented at `catalogue/README.md` in the
abdm-docs repository; read it before adding any non-atom file to the
tree.

## Related

- The prose rules: `writing-guide`
- Reviewing before merge: `atom-review`
- Fixing lint failures: `catalogue-linting`
- Where atoms come from: `openapi-ingest`
- Scaffold a new one: `/atom-new`
