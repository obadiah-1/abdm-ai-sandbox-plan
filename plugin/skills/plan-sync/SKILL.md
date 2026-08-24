---
name: plan-sync
description: How the ABDM Developer Portal architecture and execution plan works as a versioned source: where it lives, how it compiles into the plan-derived skills, the manifest staleness check, and what to do when the installed plan version is older than the published one. Use whenever the plan changes, when a skill's plan_version does not match the manifest, when someone asks whether the plugin is working from the current plan, when editing the plan itself, or when deciding whether a question should be answered from a compiled skill or by retrieving the plan.
---

# Plan Sync

The plan is a source, not a document people transcribe. It is watched, hashed, reviewed and compiled like any NHA specification.

## Where the plan lives

Canonical copy, the only editable one, in the plan repo:

```
abdm-v1-phase1-architecture-and-plan.md    the plan
plan-as-source-addendum.md                 how it stays authoritative
manifest.json                              version, hash, compiled skill list
plan-history/                              superseded versions, never deleted
scripts/plan-check.sh                      the drift gate
plugin/                                    this plugin, built from the plan above
```

Repo: `https://github.com/obadiah-1/abdm-ai-sandbox-plan`

Published surfaces:

| Surface | For |
|---|---|
| `.../blob/main/abdm-v1-phase1-architecture-and-plan.md` | People reading it |
| `.../raw/main/abdm-v1-phase1-architecture-and-plan.md` | Agents fetching raw markdown |
| `.../raw/main/manifest.json` | Cheap staleness checks |
| `.../commits/main/abdm-v1-phase1-architecture-and-plan.md` | What changed and when |
| Docs MCP and llms.txt | Question answering and discovery, once the docs site is up |

The plugin ships in the same repo as the plan it is compiled from. That is deliberate: a plan change and the skill rebuild it forces land in one commit and one review, so the two cannot drift apart between repos.

It is in git because hashing, diffing and pull request review are the mechanism. A plan in a collaboration tool with no content hash cannot be watched, and a change with no review gate cannot be trusted. GitHub's commit history for the plan file is the changelog; `plan-history/` holds the full superseded text so a stale skill's basis can be read without reconstructing it from diffs.

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

One small file at the repo root, fetched once at session start by the index skill from
`https://raw.githubusercontent.com/obadiah-1/abdm-ai-sandbox-plan/main/manifest.json`.

```json
{
  "plan_version": "2026.08.24",
  "plan_hash": "sha256:06c6c63f...",
  "plan_path": "abdm-v1-phase1-architecture-and-plan.md",
  "plan_url": ".../raw/main/abdm-v1-phase1-architecture-and-plan.md",
  "plan_page_url": ".../blob/main/abdm-v1-phase1-architecture-and-plan.md",
  "changelog_url": ".../commits/main/abdm-v1-phase1-architecture-and-plan.md",
  "history_path": "plan-history/",
  "breaking": false,
  "compiled_skills": ["portal-architecture", "portal-planning", "dpg-governance", "abdm-portal-index"]
}
```

`compiled_skills` is the authoritative list of what a plan change forces a rebuild of. Adding a fifth plan-derived skill means adding it here, or the gate will not check it.

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

1. Branch, edit `abdm-v1-phase1-architecture-and-plan.md`
2. Copy the version you are replacing to `plan-history/plan-<old plan_version>.md`. Never delete one
3. Recompile the four skills in `plugin/skills/` from the edited plan, and restamp `plan_version` in each one's frontmatter
4. Bump `plan_version` and `plan_hash` in `manifest.json`. Set `breaking: true` if a principle, a date, an owner or a definition of done criterion changed

   `plan_version` is the date of the change, `2026.08.24`. A second change on the same day appends a counter, `2026.08.24-2`, then `-3`. Dates sort correctly as strings and tell a reader how stale they are at a glance, which a serial number does not. Never reuse a version: a skill stamped with one is claiming to be built from exactly that text.
5. Run `./scripts/plan-check.sh`. It fails until steps 3 and 4 are both done, which is the point: the plan cannot move without the plugin moving with it
6. Open a pull request. The diff shows the plan change **and the diff of the four compiled skills** side by side, because a small prose change can materially change a compiled instruction. Review against four questions: does this change a principle, a date, an owner, or a definition of done criterion
7. Merge. The manifest at `main` is now what installed plugins compare themselves against

Steps 3 to 5 are not optional politeness. `scripts/plan-check.sh` is the enforcement: it hashes the plan, compares against `manifest.json`, and checks the stamp in every skill named in `compiled_skills`. A plan edit that skips the rebuild fails the gate loudly instead of shipping skills that quietly describe a plan nobody agreed to.

## Validator rules specific to the plan

| Rule | Catches |
|---|---|
| `plan.principles-complete` | A principle in the plan that reaches no compiled skill, and is therefore unenforceable |
| `plan.section-refs-resolve` | A skill citing a plan section id that does not exist |
| `plan.no-new-commitments` | The prose pass inventing a date, owner, checkpoint or done criterion |
| `plan.done-criteria-count` | Silent loss of a done criterion between the plan and `portal-planning` |
| `scripts/plan-check.sh` | The plan edited without bumping the manifest, or without restamping a compiled skill. The one rule that runs with no build system present |

The last one exists because losing a done criterion is invisible at review time and expensive at ship time.

## Citing plan sections

Every section carries a stable id, declared in the plan as an anchor tag on the line above its heading:

```markdown
<a id="p4-skills"></a>
## 4. Skills, plugin and index: compiled, not written
```

Skills cite `plan#p4-skills`. The scheme is `p<section number>-<short slug>`, and subsections append their own number, `p4-2-ooda` for §4.2. The id is deliberately shorter than the heading and independent of it, so rewording a heading breaks nothing.

Do not cite GitHub's generated heading anchor. It is derived from the full heading text and changes on any reword, which is the exact failure the ids exist to prevent.

**Renaming or removing a section id is a breaking change.** Bump with `breaking: true` and fix every citation in the same commit, exactly as with renaming an atom id. `scripts/plan-check.sh` greps every plan section citation in the plugin and fails on any that no longer resolves, so a rename cannot be half-done.

The section number in an id is a label, not a promise about ordering. Renumbering headings does not force an id change, and does not have to: `p4-skills` stays `p4-skills` even if it becomes section 5, because the id is what citations depend on. Only rename an id when the section it names is genuinely gone or has become something else.

## What this does not solve

The plan has one owner. This keeps the plugin honest about the plan; it does not make the plan correct. A wrong plan compiles cleanly into confidently wrong skills, faster than before. The review gate is the only defence and it is human.

## Related

- What the plan says: `portal-architecture`, `portal-planning`
- The same pipeline for NHA sources: `update-pipeline`
- Why runtime dependencies are constrained: `dpg-governance`
- Check it: `/plan-check`
