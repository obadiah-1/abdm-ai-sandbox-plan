# abdm-portal

The plugin for building the ABDM Developer Portal.

This plugin does not integrate anyone with ABDM. It builds the thing that does. Every skill here serves one of the five workstreams in the architecture and execution plan: Catalogue, Scalar, Skills, Pipeline, Proof.

## Install

Install the whole plugin:

```
/plugin install abdm-portal
```

Or install one skill at a time. Start with `abdm-portal-index`, which routes to everything else:

```
skills install abdm-portal-index
```

## What is in here

**Router**

- `abdm-portal-index` routes any request to the right skill, agent, command or reference. Install this first.

**Understanding the project**

- `portal-architecture` the four building blocks, the seven principles, what is deliberately out of scope
- `portal-planning` the schedule, the two-day increments, the definition of done, ownership split
- `dpg-governance` the FOSS and no-Eka-dependency constraint, and how to check it holds
- `plan-sync` how the plan works as a versioned source, and the staleness check

The first three are compiled from `catalogue/governance/plan.md`, along with the index. Do not edit them by hand.

**Building the Catalogue**

- `atom-authoring` how to write one atom: frontmatter schema and the five dummy-proof sections
- `writing-guide` the binding prose rules, including no em dashes
- `atom-review` how to review an atom before it can be merged
- `catalogue-lint` the CI rules and how to fix each failure
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

Commands in `commands/` are the day-to-day verbs: create an atom, verify one, lint the Catalogue, compile skills, publish docs, check sources, run the eval set, run the first-day test, produce the standup, and check the plan version.

## Keeping up with the plan

The architecture and execution plan lives at `catalogue/governance/plan.md` in the public repo and publishes to the docs site. Four skills compile from it. A small manifest lets an installed plugin notice when it is older than the published plan and say so, without fetching instructions at runtime. Run `/plan-check` to see where you stand.

## The one rule that binds everything

The Catalogue is the only source. Docs, skills, the index, llms.txt and both MCP surfaces are build outputs. Nothing downstream is hand-maintained. If a skill names an endpoint or an error code the Catalogue does not have, the build fails.
