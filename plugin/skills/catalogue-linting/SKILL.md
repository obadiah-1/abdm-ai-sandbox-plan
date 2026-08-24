---
name: catalogue-linting
description: Every mechanised check that runs against the ABDM Catalogue in CI, what each failure message means, and how to fix it. Covers schema validation, the five mandatory sections, the em dash block, link and id resolution, source hash presence, OpenAPI Spectral linting, and the identifier diff that stops compiled skills inventing facts. Use whenever CI is red on the Catalogue, a build fails, someone asks why their atom was rejected, or when adding or changing a lint rule.
---

# Catalogue Lint

Lint is the enforcement layer for the principles. Every rule here exists because a principle would otherwise be a wish. When a rule blocks you, the fix is the content, never the rule.

Run everything locally before pushing: `/catalogue-lint`.

## The rule set

### Schema rules

| Rule | Failure message | Fix |
|---|---|---|
| `schema.required` | `missing required field: <field>` | Add the field. See `atom-authoring` for the full schema. |
| `schema.id-format` | `id must be gateway.type.slug` | Lowercase, three parts, matches the file's location. |
| `schema.id-unique` | `duplicate id: <id>` | Ids are never reused. Pick a new slug; do not recycle a retired one. |
| `schema.gateway-enum` | `gateway must be one of hiecm, uhi, shared` | Fix the value. Shared atoms use `milestone: n/a`. `nhcx` is not in the enum because NHCX is out of scope, and that is the enforcement, not an oversight. |
| `schema.type-enum` | `unknown type: <type>` | One of the ten types. If it fits none, it is probably two atoms. |
| `schema.verified-enum` | `verified.status must be verified, unverified or stale` | Fix. If unsure, `unverified` is always safe. |
| `schema.verified-evidence` | `status is verified but no response block found in body` | Either record the observed response or set `unverified`. This rule exists to stop fabricated verification. |

### Section rules

| Rule | Failure message | Fix |
|---|---|---|
| `sections.present` | `missing section: <name>` | All five headings, in order, on every atom. Glossary atoms may write "Nothing" under a heading but the heading stays. |
| `sections.order` | `sections out of order` | In plain words, Before you start, What happens, How you know it worked, When it goes wrong. |
| `sections.empty` | `section <name> is empty` | Write it. An empty section 5 usually means the author did not know the failures; say that instead. |
| `sections.exit-condition` | `section 4 has no observable statement or exit-condition block` | Name what arrives and within how long. This is the exit condition compiled skills depend on. |

### Prose rules

| Rule | Failure message | Fix |
|---|---|---|
| `prose.no-em-dash` | `U+2014 found at line N` | Replace with a full stop, comma or colon. No exceptions, including inside code comments and commit messages. |
| `prose.banned-words` | `banned word "<word>" at line N` | See the table in `writing-guide`. |
| `prose.acronym-linked` | `acronym <X> used without glossary link` | Link on first use in every atom, not the first use in the Catalogue. |
| `prose.placeholder-named` | `placeholder <TOKEN> does not name its source` | `<ACCESS_TOKEN_FROM_SESSIONS_CALL>` rather than `<TOKEN>`. |

### Graph rules

| Rule | Failure message | Fix |
|---|---|---|
| `graph.related-resolves` | `related id does not exist: <id>` | Create the atom or remove the link. Never leave a dangling id. |
| `graph.skills-exist` | `skills entry has no template: <skill>` | Match a skill in the compiler's set, or remove. |
| `graph.flow-steps` | `flow step <n> has no endpoint atom` | Every step in a sequence diagram needs a corresponding endpoint atom in `related.endpoints`. |
| `graph.orphan` | `atom is referenced by nothing` | Warning, not an error. Some atoms are legitimately entry points. Confirm it is reachable from navigation. |

### Source rules

| Rule | Failure message | Fix |
|---|---|---|
| `source.present` | `no sources listed` | Every atom has at least one source. If the source is our own analysis, say so and mark `docs-only`. |
| `source.hash` | `source has no hash` | Ingestion records it. If hand-added, run `/source-check` to compute. |
| `source.stale` | `source hash differs from stored: atom should be stale` | The watcher normally does this. If you hit it manually, set `stale` and open the review. |

### OpenAPI rules

Spectral runs over the module specification files under `catalogue/openapi/` (`hiecm-gateway.yaml`, `hiecm-m1.yaml` through `-m4.yaml`).

| Rule | Failure message | Fix |
|---|---|---|
| `oas.valid` | Spectral rule violations | Fix in the ingested file, and record the correction in `sources` alongside the original. Never silently edit an NHA file without recording it. |
| `oas.operation-id` | `operation missing operationId` | Endpoint atom stubs are generated from operation ids. Add one and note the addition as a correction. |
| `oas.callbacks-webhooks` | `callback described outside the module's webhooks section` | Callbacks live inside the module spec file that owns them, as OpenAPI 3.1 `webhooks` entries, per `CONVENTIONS.md`, so Scalar renders them from the same reference. There is no AsyncAPI file anywhere in the stack. |

### Compiled output rules

These run after the compiler and are the hardest rules in the repo.

| Rule | Failure message | Fix |
|---|---|---|
| `compile.identifier-diff` | `skill contains identifier not in Catalogue: <token>` | The prose pass invented something. Do not add the token to the Catalogue to make the build pass unless it is genuinely real and sourced. Regenerate. |
| `compile.sections` | `compiled skill missing required section` | Template problem, not content. See `skill-compiler`. |
| `compile.frontmatter` | `SKILL.md frontmatter invalid` | Name and description are mandatory and the name must match the directory. |
| `compile.index-complete` | `index does not list <skill>` | The index is generated last. This means a skill was produced after the index walk; fix build ordering. |
| `compile.gateway-coverage` | `gateway <g> has zero verified atoms` | P1 enforcement. The index refuses to build. Either verify something or the gateway is not shippable. |

## When a rule seems wrong

Two legitimate responses and one illegitimate one.

Legitimate: the rule has a false positive, so fix the rule and add a test case for the atom that tripped it. Or the atom is genuinely an exception, so add an explicit, reviewed, commented exemption with an expiry.

Illegitimate: weakening the rule to get a build green. In particular, never add an invented identifier to the Catalogue to satisfy `compile.identifier-diff`. That rule failing means the system worked.

## Local run

```
/catalogue-lint             # everything
/catalogue-lint --atoms     # schema, sections, prose, graph
/catalogue-lint --oas       # Spectral only
/catalogue-lint --compiled  # post-compile checks
/catalogue-lint --fix       # only the mechanically safe fixes: ordering, whitespace, em dash replacement
```

`--fix` never touches meaning. It will not write prose, resolve a link, or change a verification status.

## Related

- What the atom should contain: `atom-authoring`
- Human review after lint passes: `atom-review`
- The compiler and its validator: `skill-compiler`
