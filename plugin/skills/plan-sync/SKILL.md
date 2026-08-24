---
name: plan-sync
description: How the ABDM Developer Portal architecture and execution plan works as a versioned source: where it lives, how it compiles into the plan-derived skills, the manifest staleness check, and what to do when the installed plan version is older than the published one. Use whenever the plan changes, when a skill's plan_version does not match the manifest, when someone asks whether the plugin is working from the current plan, when editing the plan itself, or when deciding whether a question should be answered from a compiled skill or by retrieving the plan.
---

# Plan Sync

The plan is a source, not a document people transcribe. It is watched, hashed, reviewed and compiled like any NHA specification.

## Where the plan lives

Canonical copy, the only editable one:

```
catalogue/governance/plan.md
catalogue/governance/plan-history/     superseded versions, never deleted
```

Published surfaces:

| Surface | For |
|---|---|
| `docs-domain/governance/plan` | People reading it |
| `docs-domain/governance/plan.md` | Agents fetching raw markdown |
| `docs-domain/governance/manifest.json` | Cheap staleness checks |
| Docs MCP and llms.txt | Question answering and discovery |

It is in git because hashing, diffing and pull request review are the mechanism. A plan in a collaboration tool with no content hash cannot be watched, and a change with no review gate cannot be trusted.

## What compiles from it

Four skills are build outputs of the plan:

- `portal-architecture`
- `portal-planning`
- `dpg-governance`
- `abdm-portal-index`

**Do not edit these four directly.** Editing the plan is the only way to change them. A hand edit is overwritten on the next build, silently, which is worse than losing it loudly.

## Retrieval versus compilation

Both are legitimate. Confusing them is the failure mode.

| Question | Answered by |
|---|---|
| What are the seven principles | Compiled skill |
| What ships at the next checkpoint | Compiled skill, with a version check |
| Why reference depth for UHI | Compiled skill |
| What changed in the plan last week | Retrieval over `plan-history` |
| Has anyone written down how we handle this | Retrieval over the whole docs site |
| Is my understanding of the schedule current | Manifest check, then retrieval if stale |

Compilation answers what the plan says. Retrieval answers what it has said over time, and finds what nobody thought to compile.

## Why skills do not fetch the plan at runtime

It looks like the same thing as retrieval and is not. Runtime fetching of instructions breaks five properties:

- Skills install alone and work offline. A network dependency on load means the skill fails when the network does.
- Content is reviewed before reaching an agent. Runtime fetching means a plan edit reaches every installed agent with no review gate.
- Builds are reproducible. Two agents running the same task the same day could get different instructions.
- P6 decoupling. A hard runtime dependency on one hosted URL is what the principle forbids.
- Identifier validation. The validator cannot diff facts it never saw at build time.

So: compile the content, and check the version cheaply.

## The manifest check

One small file, fetched once at session start by the index skill.

```json
{
  "plan_version": "2026.08.24",
  "plan_hash": "sha256:...",
  "catalogue_version": "2026.08.30",
  "plan_url": "https://docs-domain/governance/plan.md",
  "changelog_url": "https://docs-domain/governance/plan-history",
  "breaking": false
}
```

Compare against the `plan_version` stamped in the loaded skill:

| Comparison | Behaviour |
|---|---|
| Match | Proceed silently. Do not mention it. |
| Manifest newer, `breaking: false` | Proceed, and say once: your skills are built from plan X, current is Y, run update when convenient. |
| Manifest newer, `breaking: true` | Say so before any planning or architecture answer, name what changed, and offer to read the plan directly for the affected question. |
| Manifest unreachable | Proceed on the installed version and say the check failed. |

**The check is advisory and never blocking.** A skill that refuses to work because it could not reach a URL is worse than one that is two days stale and says so.

Check once per session, not per question. Repeating the notice is noise.

## Editing the plan

1. Branch, edit `catalogue/governance/plan.md`
2. Open a pull request. The preview shows the rendered plan **and the diff of the four compiled skills**, because a small prose change can materially change a compiled instruction
3. Review against four questions: does this change a principle, a date, an owner, or a definition of done criterion
4. Bump `plan_version`. Set `breaking: true` if a principle or a done criterion changed
5. Merge. CI lints the plan, compiles the four skills, validates, regenerates the index, publishes the docs page, raw markdown, manifest and plugin release
6. The previous version is copied to `plan-history` and never deleted

## Validator rules specific to the plan

| Rule | Catches |
|---|---|
| `plan.principles-complete` | A principle in the plan that reaches no compiled skill, and is therefore unenforceable |
| `plan.section-refs-resolve` | A skill citing `plan#some-id` that does not exist |
| `plan.no-new-commitments` | The prose pass inventing a date, owner, checkpoint or done criterion |
| `plan.done-criteria-count` | Silent loss of a done criterion between the plan and `portal-planning` |

The last one exists because losing a done criterion is invisible at review time and expensive at ship time.

## Section ids

Every plan section carries a stable id, so skills cite `plan#p4-ooda` rather than a heading number that moves when a section is inserted. Renaming a section id is a breaking change and needs a redirect, exactly like renaming an atom id.

## What this does not solve

The plan has one owner. This keeps the plugin honest about the plan; it does not make the plan correct. A wrong plan compiles cleanly into confidently wrong skills, faster than before. The review gate is the only defence and it is human.

## Related

- What the plan says: `portal-architecture`, `portal-planning`
- The same pipeline for NHA sources: `update-pipeline`
- Why runtime dependencies are constrained: `dpg-governance`
- Check it: `/plan-check`
