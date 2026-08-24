# ABDM Developer Portal, project folder

Everything for the ABDM Developer Portal V1 in one place.

## Contents

- `abdm-v1-phase1-architecture-and-plan.md` the base architecture and execution plan. Four building blocks, the seven principles, the atom model, the OODA skill loops, the update pipeline, the schedule and definition of done.
- `plan-as-source-addendum.md` how the plan itself becomes a versioned source so the plugin never drifts from it. Read this second; it extends the plan above rather than replacing it.
- `plugin/` the `abdm-portal` plugin: 16 skills, 6 agents, 11 commands that build and operate the portal. Install this to start work. See `plugin/README.md`.

## Reading order

1. `abdm-v1-phase1-architecture-and-plan.md`, for what is being built and why
2. `plan-as-source-addendum.md`, for how the plan stays authoritative as it changes
3. `plugin/README.md`, for the tools that do the work

## The one thing to remember

The plan is the base layer. The plugin's `portal-architecture`, `portal-planning`, `dpg-governance` and index skills are compiled from `abdm-v1-phase1-architecture-and-plan.md` and its governance section, not written by hand. When the plan changes, those skills are rebuilt, never edited directly. See `plugin/skills/plan-sync/SKILL.md`.
