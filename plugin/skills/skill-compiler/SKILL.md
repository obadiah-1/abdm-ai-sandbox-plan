---
name: skill-compiler
description: How ABDM Catalogue atoms are compiled into agent skills, the plugin bundle and the generated index, including the selector, templates, the constrained prose pass, and the validator that stops invented facts. Use whenever working on the compiler, debugging a compile or validation failure, adding a new skill kind, changing a template, or explaining why compiled skills must never be hand-edited.
---

# Skill Compiler

Skills are build outputs. Nobody writes a SKILL.md for ABDM by hand. If a compiled skill is wrong, the atom is wrong, or the template is wrong. Editing the output fixes nothing and gets overwritten on the next build.

## Two inputs, one pipeline

The compiler has two sources. Atoms produce the gateway skills. The architecture and execution plan produces four skills about the portal itself: `portal-architecture`, `portal-planning`, `dpg-governance` and `abdm-portal-index`. Same templates, same prose constraints, same validator, and the same rule that the output is never hand-edited.

The plan's authoritative list of its own outputs is `compiled_skills` in `manifest.json`. Read it from there rather than hardcoding four names, so adding a fifth plan-derived skill does not need a compiler change.

Every plan-derived skill carries four extra frontmatter keys, written by the compiler, never by hand:

```yaml
plan_version: 2026.08.24
plan_source: abdm-v1-phase1-architecture-and-plan.md
plan_hash: sha256:06c6c63f...
compiled_from_plan: true
```

The stamp is what lets an installed skill compare itself against the published manifest, and what `scripts/plan-check.sh` checks. A compile that produces content but forgets the stamp produces a skill that can never notice it is stale, which is the failure this whole mechanism exists to prevent. Mechanism and the editing procedure: `plan-sync`.

## The pipeline

```
Catalogue atoms                  Plan (abdm-v1-phase1-architecture-and-plan.md)
   -> Selector       reads atom.skills[], gathers atoms per target skill
   -> Templates      one per skill kind: index, orient, build, test, debug, bundle
   -> Compiler       deterministic assembly, then a constrained prose pass
   -> Validator      identifiers, links, sections, frontmatter, em dashes
   -> Output         plugins/abdm/skills/*/SKILL.md + references/ + scripts/
   -> Index          generated last, by walking the atom graph
   -> Bundle         plugin manifest, plus per-skill install
```

## Selector

Reads `skills:` in each atom's frontmatter. An atom can feed several skills; the M2 link flow feeds both `hiecm-m2-build` and `hiecm-m2-test`, in different roles.

Rules:

- An atom with no `skills` entry never reaches an agent. That is correct for glossary and decision atoms and a mistake for flows. The selector warns on flows with no skill target.
- Error atoms feed the milestone debug skill and the cross-gateway `abdm-errors` skill.
- Test atoms feed test skills only.
- An atom marked `stale` still compiles, but the compiler injects a warning line into the skill: this step may have changed, check the docs.

## Templates

One per kind. Templates contain structure and the invariant instructions; they contain no ABDM facts.

| Kind | Structure it imposes |
|---|---|
| index | Decision tree, skill and agent and tool inventory, `catalogue_version` |
| orient | Concepts and scoping, no execution steps |
| build | OODA loop per flow step, scaffolding instructions, atom citations |
| test | OODA loop per test case, human-required markers, pass and fail recording |
| debug | OODA loop per hypothesis, error atom walk, escalation format |
| bundle | Manifest listing everything, no content of its own |

Changing a template changes every skill of that kind on the next build. That is the point, and it is also why template changes need review as carefully as content.

## The constrained prose pass

Deterministic assembly produces stilted text that agents follow badly. So an LLM pass rewrites it, under hard constraints:

- It is given the `writing-guide` and the assembled content, nothing else
- It may reword, reorder within a section, and improve transitions
- It may not add a fact, an identifier, a header name, a URL, a status code or an error code
- It may not remove a warning, a precondition or an exit condition

The prose pass is the only non-deterministic step. Everything after it exists to check it.

## The validator

Runs after the prose pass. Failures here are build blockers.

| Check | What it does |
|---|---|
| Identifier diff | Extracts every identifier, URL, header name, status code and error code from the output and diffs against the Catalogue. Any token not present fails. |
| Link resolution | Every atom id cited exists. Every internal link resolves. |
| Section presence | The template's required sections are all present in the output. |
| Frontmatter validity | Name matches directory, description present, both parse as YAML. |
| Em dash | U+2014 anywhere fails. |
| Exit conditions | Every loop in a build, test or debug skill has an exit condition traceable to an atom's section 4. |
| Loop limits | Every loop declares a limit and an escalation. |

**When the identifier diff fails, the system worked.** The prose pass invented something. Regenerate. Never add the invented token to the Catalogue to make the build pass, unless it turns out to be real, in which case it needs a source and a verification like any other fact.

## The index

Generated last, because it walks everything else. It carries:

- Every skill, agent and tool with a one-line trigger description
- The decision tree: what are you building, which gateway, which milestone, build or test or debug
- Which steps are independent, which is what permits parallel loops
- Depth labels per gateway
- `catalogue_version`, so an agent can tell a developer their skills are older than the docs and to update

The index is the only skill that must be loaded for an agent to discover the rest. It is therefore the one whose trigger description matters most.

## Per-skill install

Every skill installs alone. An integrator debugging M2 on a Tuesday should not have to load M1 build instructions. The bundle exists for people who want everything, not as the default path.

This constrains the templates: no skill may depend on another skill being loaded. Shared context is repeated, not referenced. Some duplication across skills is the correct trade.

## Adding a new skill kind

1. Decide what its exit condition is. If you cannot state one, it is not a skill, it is a reference.
2. Write the template with structure only.
3. Add the kind to the validator's expectations.
4. Add it to the index generator's inventory.
5. Compile against real atoms and read the output as an agent would.

## Debugging a compile failure

| Symptom | Usual cause |
|---|---|
| Skill missing content you expected | Atom's `skills:` list does not name it |
| Identifier diff fails on something real | The fact is in prose but not in a structured block, so extraction missed it |
| Exit condition missing | Atom's section 4 is not observable. Fix the atom, not the template. |
| Index missing a skill | Build ordering: the skill was produced after the index walk |
| Gateway coverage failure | A gateway has zero verified atoms. P1 refuses to build. |

## Related

- Writing loops properly: `ooda-skill-authoring`
- The atoms that feed it: `atom-authoring`
- The checks: `catalogue-linting`
- Run it: `/skills-compile`
