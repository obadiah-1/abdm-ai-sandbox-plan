# The plugin as the portal's bible

Date: 2026-08-27
Status: approved design, not yet implemented
Branch of origin: feat/plan-reconcile-with-abdm-docs

## The problem

The `abdm-portal` plugin was built as the tool Eka uses to build the portal. It
now has to become the manual anyone uses to build or maintain any part of it:
NHA, partner contributors, anyone who forks it. Two things stop that today.

**The plugin is not true.** It describes `eka-care/abdm-docs` from another
repository, and has drifted from it. Confirmed drift, found by sampling rather
than by an exhaustive pass:

| Plugin says | `abdm-docs` actually has |
| --- | --- |
| `verified.status` is one of three values | Four: `draft`, `unverified`, `verified`, `stale` |
| OpenAPI at `catalogue/openapi/hiecm-m1.yaml` | `catalogue/openapi/<platform>/<version>/<name>.yaml` |
| HIE-CM M4 is Phase 2, nothing written | `hiecm-m4.yaml` committed, plus `p1` to `p3` and `phr-services`, none of which the plugin mentions |
| NHCX is out of scope | True for atoms only. `site/docs/nhcx/`, `catalogue/openapi/nhcx/v1/` and NHCX roles are live. Nothing states the split |
| Site is four tabs | A Docusaurus tree with platforms, versions, `_platform.json`, role facets and generated `endpoints/` |
| Nothing about page content rules | A 242 line content paradigm: word budgets per page type, `description` at 160 characters, `## In short` above 300 words, banned Introduction and Overview headings, 25 and 35 word sentence tiers |
| README claims 17 skills | 18 skill directories |

`catalogue/README.md` defers to the plugin's `atom-authoring` skill for "the
full rules" while the plugin describes the repository. That citation loop is
the root cause. Neither side is grounded.

**Nothing binds a contributor.** `abdm-docs` has no `CLAUDE.md` and no
`AGENTS.md`. A contributor who clones it and points an agent at it gets none
of the paradigm. The agent invents a structure, and finds out at pull request
time, if a check happens to catch it. No check catches "one page, one job".

## Decisions

1. The plugin moves into `abdm-docs/.claude/plugin/` and lives there. It stops
   describing a repository it cannot see.
2. This repository becomes plan only. It keeps publishing `manifest.json`,
   which `plan-sync` already fetches over the network.
3. A deterministic, blocking vetter runs in `abdm-docs` CI. Node, not Python,
   to match the repository and to reuse `scripts/lib/atoms.mjs`.
4. The plugin auto-loads on clone, so a contributor is bound without installing
   anything.
5. The plugin is agnostic to who is contributing. Routing is by what is being
   changed, never by who is changing it.
6. The drift is audited in full and fixed before the rest ships.

## What "agnostic" means, precisely

It does not mean deleting the word Eka. Most of the 19 occurrences in the
plugin are the constraint itself: no Eka dependency, no `eka.care` URL in the
core Catalogue, the DPG acceptance test. Those are what make it agnostic and
they stay.

Two occurrences are genuinely audience coded and change:

- `support-agent` describes "an agent for the Eka support team". It becomes an
  agent any operator runs against their own Docs MCP endpoint.
- `portal-planning` carries an Eka shaped ownership split. Ownership becomes a
  role, not an organisation.

NHA stays throughout, as the upstream source of truth. It never appears as a
class of author. No author class gets different rules.

## Non-goals

- Rewriting the seven existing checks in `abdm-docs`. They are the mechanical
  floor and they stay exactly as they are.
- An agent that reviews pull requests. Rejected in favour of a deterministic
  gate.
- Any change to the plan, the plan compiled skills, or the gantt.
- Phase 2 content: UHI and HIE-CM M4 atoms. Structure only.

## Where things live after the move

```
abdm-ai-sandbox-plan/            plan only
  abdm-v1-phase1-architecture-and-plan.md
  manifest.json                  published, fetched by plan-sync
  plan-history/
  scripts/plan-check.sh
  gantt/

abdm-docs/
  .claude/
    settings.json                declares and enables the local plugin
    plugin/                      the plugin, its home
      .claude-plugin/plugin.json
      skills/  agents/  commands/
    skills/                      fallback if project settings do not auto-enable
  AGENTS.md                      the floor. CLAUDE.md symlinks to it
  catalogue/                     unchanged
  site/                          unchanged
  scripts/
    vet-change.mjs               the blocking vetter
    lib/atoms.mjs                reused by it
```

The four plan compiled skills still compile from the plan and carry their
`plan_version` stamp. They travel with the plugin into `abdm-docs` and fetch
`manifest.json` to notice they are stale, which is what `plan-sync` already
describes. The plan is design intent and outlives any repository, so it is the
one thing that legitimately lives apart.

## Components

### 1. The move

Move `plugin/` to `abdm-docs/.claude/plugin/`. Update
`.claude-plugin/marketplace.json` in this repository to stop listing it, and
move the marketplace declaration into `abdm-docs`. Fix the skill count in the
plugin README to 18.

`scripts/plan-check.sh` currently walks `plugin/skills/<name>/SKILL.md` to
verify the `plan_version` stamps. After the move those files are in another
repository, so the check moves to `abdm-docs` CI alongside the vetter. This
repository's gate keeps only the parts that are local: the plan hash against
the manifest, and the gantt generator's stamp.

### 2. Auto-load wiring

`abdm-docs/.claude/settings.json` declares a directory marketplace pointing at
`.claude/plugin/` and enables it, so a contributor who clones the repository and
opens Claude Code has the plugin loaded with no install step.

This is the one unverified assumption in the design. `enabledPlugins` and
`extraKnownMarketplaces` are confirmed settings keys, and `extraKnownMarketplaces`
accepts a `directory` source. It is not confirmed that a project level
`settings.json` honours them, because auto-enabling a plugin from a cloned
repository may be gated behind a trust prompt by design.

Verify this first, before anything else in this spec. If it does not hold, the
fallback is `.claude/skills/`, which is auto-discovered with certainty. The
plugin's skills are copied there by a build step and the vetter checks the copy
against its source. Commands and agents are then only available to someone who
installs the plugin, and the skills, which carry the rules, are available to
everyone. Same outcome for the guardrails, one build step more.

### 3. AGENTS.md, the floor

A short file at the `abdm-docs` root, with `CLAUDE.md` symlinked to it, so any
agent reading either convention is bound. It is short on purpose: it states the
refusals, names the commands, and points at the plugin for everything else.

Refusals, in the imperative:

- Never set `verified`. Only a recorded run against sandbox does that.
- Never edit a file carrying `generated: true`, or anything under `endpoints/`.
- Never invent an identifier to make a build pass.
- Never add a vendor hostname to the core Catalogue.
- Never claim the work is done without pasting the output of the checks.

### 4. The vetter

`abdm-docs/scripts/vet-change.mjs`, run as `npm run vet`, wired into CI as a
required check. It is diff aware, which is what makes it different from every
check already there. It reuses `scripts/lib/atoms.mjs` so it cannot disagree
with `lint-atoms.mjs` about what an atom is.

**Rule group A, alignment.** The bible cannot drift from the repository again.

| Rule | Fails when |
| --- | --- |
| `align.plugin-stamp` | A limit, enum or path changed in a linter or in the tree, and no plugin skill changed in the same pull request |
| `align.skills-copy` | The `.claude/skills/` copy does not match its source in `.claude/plugin/`, under the fallback wiring |
| `align.plan-stamp` | A plan compiled skill's `plan_version` does not match the published `manifest.json` |

`align.plugin-stamp` is the rule that would have caught every row in the drift
table. It reads the constants out of `lint-atoms.mjs`, `lint-content.mjs` and
`lint-agent-readiness.mjs`, walks the live tree for platforms, versions and
spec files, hashes the result, and compares against a hash stamped in the
plugin. Changing a limit without updating the bible fails the build.

**Rule group B, diff aware refusals.** None of these are catchable file by
file, which is why no existing check catches them.

| Rule | Fails when |
| --- | --- |
| `diff.verified-without-evidence` | `verified.status` moves to `verified` in the diff with no response block added in the same diff |
| `diff.generated-edited` | A file carrying `generated: true`, or any file under `endpoints/`, is modified by hand |
| `diff.generated-name-collision` | A hand written page is added at a generated name: `api/index.md`, `api/<module>/errors.md`, `reference/{authentication,callbacks,error-codes}.md` |
| `diff.spec-stem-collision` | A spec is added whose filename stem already exists under another gateway or version |
| `diff.vendor-url` | A vendor hostname is added to the core Catalogue |

**Rule group C, placement.** A file added at a path the tree contract does not
recognise fails, naming the paths that are valid for that kind of file.

### 5. What the vetter cannot check

Stated in the vetter's own output and in `AGENTS.md`, so the gate is not
oversold:

- Whether a page does one job
- Whether prose is honest
- Whether a verification claim reflects a real run
- Whether an atom is the right atom to have written

Those stay with the agent while writing, guided by the plugin, and with a human
at review. A deterministic vetter that claimed to check judgement would be
worse than one that says plainly what it does not cover.

### 6. Plugin content changes

| Skill | Change |
| --- | --- |
| `atom-authoring` | Fix the drift: four verification statuses, real OpenAPI paths, the NHCX atom and site split |
| `page-authoring` | New. The content paradigm for `site/docs`: budgets, `## In short`, banned first headings, the six questions, one page one job. Nothing in the plugin covers site pages today, and this is half of what contributors generate |
| `openapi-ingest` | Absorb `catalogue/openapi/CONVENTIONS.md`: `operationId` format, callbacks as OpenAPI 3.1 webhooks, self contained files, the `x-abdm-*` facets, and the `x-portal` versus `x-abdm-*` inconsistency resolved one way |
| `catalogue-linting` | Rule table regenerated from the actual checks, plus the vetter's rules |
| `docs-ux` | Rewrite against the real Docusaurus tree: platforms, versions, roles, `_platform.json`, generated `endpoints/` |
| `abdm-portal-index` | Route by what is being changed. Add the contributor entry and the refusals |
| `support-agent` | De-Eka: an agent any operator runs |
| `portal-planning` | Ownership as a role, not an organisation |

## Order of work

1. Verify the project level plugin auto-load assumption. It decides section 2.
2. Full drift audit. Every plugin claim against `abdm-docs`, as a table, on the
   record. It will find more than the seven rows above.
3. Move the plugin. Split `plan-check.sh`.
4. Fix the drift the audit found.
5. Write `page-authoring`. Re-aim the skills listed above.
6. Build the vetter. Group A first, because it is the rule that keeps the rest
   true.
7. `AGENTS.md` and the `CLAUDE.md` symlink.
8. Wire the vetter into CI as a required check.

Steps 1 to 4 are one pull request in each repository. Steps 5 to 8 follow.

## Risks

- **The auto-load assumption fails.** Mitigated by the `.claude/skills/`
  fallback, which is certain. Verified first for that reason.
- **`align.plugin-stamp` becomes noisy.** A contributor changing a linter now
  has to touch the plugin too. That is the intended cost. If it fires on
  changes that are genuinely unrelated, narrow what feeds the hash rather than
  weakening the rule.
- **The audit finds more than expected.** Likely. It is sequenced before the
  pipeline work so the scope is known before anything is built on top.
- **Moving the plugin breaks installed copies.** Anyone on
  `abdm-portal@abdm-portal` needs to reinstall from the new location. One
  announcement, and the old marketplace entry points at the new one.

## Definition of done

- A contributor with no Eka involvement clones `abdm-docs`, opens an agent, and
  the plugin's rules are in context on the first turn.
- Every claim the plugin makes about `abdm-docs` is true, and a check fails if
  one stops being true.
- A pull request that sets `verified` without evidence, edits a generated file,
  or collides with a generated name is blocked, whoever opened it and whether
  or not they used an agent.
- The plugin names no organisation as a class of author.
