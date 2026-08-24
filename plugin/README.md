# abdm-portal

The plugin for building the ABDM Developer Portal.

This plugin does not integrate anyone with ABDM. It builds the thing that does. Every skill here serves one of the five workstreams in the architecture and execution plan: Catalogue, Scalar, Skills, Pipeline, Proof.

## Install

The plan repo is itself a marketplace, so this is two commands:

```sh
claude plugin marketplace add obadiah-1/abdm-ai-sandbox-plan
claude plugin install abdm-portal@abdm-portal
```

Restart Claude Code afterwards. `claude plugin details abdm-portal` lists every component and its token cost.

Working on the plugin itself: add your checkout as the marketplace instead, and re-run `claude plugin marketplace update abdm-portal` after each change.

## Two rules the manifest will not forgive

**Validate before committing.** A malformed `plugin.json` fails the whole plugin, not the part that is wrong, and nothing loads:

```sh
claude plugin validate ./plugin --strict
```

The manifest names no `skills`, `agents` or `commands` paths on purpose. The default layout is discovered automatically, and the `agents` key does not take a directory string.

**Skills and commands share one namespace.** No skill may have the same name as a command, or one shadows the other. That is why the lint rules live in the `catalogue-linting` skill while `/catalogue-lint` runs them.

## What is in here

**Router**

- `abdm-portal-index` routes any request to the right skill, agent, command or reference. Install this first.

**Understanding the project**

- `portal-architecture` the four building blocks, the seven principles, what is deliberately out of scope
- `portal-planning` the schedule, the two-day increments, the definition of done, ownership split
- `dpg-governance` the FOSS and no-Eka-dependency constraint, and how to check it holds
- `plan-sync` how the plan works as a versioned source, and the staleness check
- `gantt-sync` the shared gantt in Google Sheets: what is a formula, what counts as done, the approval gate before any write

The first three are compiled from `abdm-v1-phase1-architecture-and-plan.md` in the repo root, along with the index. Do not edit them by hand. Each carries a `plan_version` stamp in its frontmatter saying which version of the plan it was built from.

**Building the Catalogue**

- `atom-authoring` how to write one atom: frontmatter schema and the five dummy-proof sections
- `writing-guide` the binding prose rules, including no em dashes
- `atom-review` how to review an atom before it can be merged
- `catalogue-linting` the CI rules and how to fix each failure
- `openapi-ingest` pulling NHA's swagger and GitHub sources in, hashing them, describing callbacks as AsyncAPI

**Rendering and compiling**

- `scalar-docs` project setup, generated navigation, versions, the two MCP surfaces
- `skill-compiler` how atoms become skills, and the validator that stops invented facts
- `ooda-skill-authoring` how to write a skill that loops instead of reciting a recipe
- `update-pipeline` the watcher, the pull request bot, and the build on merge
- `support-agent` the internal support agent on the Docs MCP

**Proving it works**

- `portal-proof` the six eval tasks and the first-day developer test

## Agents

Sub-agent definitions live in `agents/`. They are dispatched for work that is long, repetitive or benefits from a fresh context: authoring a batch of atoms, verifying curls against sandbox, compiling and validating skills, watching sources, answering support questions, and adversarially reviewing before ship.

## Commands

Commands in `commands/` are the day-to-day verbs: create an atom, verify one, lint the Catalogue, compile skills, publish docs, check sources, run the eval set, run the first-day test, produce the standup, check the plan version, and update the shared gantt.

## Keeping up with the plan

The architecture and execution plan lives at [`abdm-v1-phase1-architecture-and-plan.md`](https://github.com/obadiah-1/abdm-ai-sandbox-plan/blob/main/abdm-v1-phase1-architecture-and-plan.md) in the repo root, one directory above this plugin. Four skills compile from it and are stamped with the `plan_version` they were built from. `manifest.json` at the repo root carries the current version and hash, so an installed plugin can notice it is older than the published plan and say so, without fetching instructions at runtime.

A plan change is not finished until the four skills are rebuilt and restamped. `scripts/plan-check.sh` enforces it: it hashes the plan, compares against the manifest, and fails if the manifest, any compiled skill or the gantt generator is behind. Run `/plan-check` to see where an installed plugin stands, or the script in a checkout.

## The one rule that binds everything

The Catalogue is the only source. Docs, skills, the index, llms.txt and both MCP surfaces are build outputs. Nothing downstream is hand-maintained. If a skill names an endpoint or an error code the Catalogue does not have, the build fails.
