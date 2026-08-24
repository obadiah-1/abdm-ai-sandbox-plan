---
name: plan-check
description: Compare the installed plan version against the published manifest and report drift in the ABDM Developer Portal plan.
---

# /plan-check

Answers one question: are these skills built from the current plan?

## Usage

```
/plan-check                  # compare installed version to the manifest
/plan-check --diff           # what changed between installed and current
/plan-check --breaking       # only report changes flagged breaking
/plan-check --offline        # report installed versions without fetching
```

## What it does

1. Reads `plan_version` from the loaded plan-derived skills
2. Fetches `manifest.json` from the docs domain
3. Compares, and reports

## Output

```
plan_version installed:  2026.08.24
plan_version published:  2026.08.31
breaking:                false
catalogue_version:       2026.08.30 installed / 2026.09.02 published

Skills built from the older plan:
  portal-architecture, portal-planning, dpg-governance, abdm-portal-index

Changed sections since installed version:
  plan#p8-schedule        checkpoint 4 moved
  plan#p9-done            one criterion added

Run: /plugin update abdm-portal
```

## Behaviour on drift

Advisory, never blocking. It reports and continues.

If `breaking: true`, it says so before any planning or architecture answer in the session and names what changed, because a changed principle or definition of done criterion means the installed skills are giving instructions that no longer reflect an agreed decision.

If the manifest is unreachable, it says the check failed and proceeds on the installed version. A failed network call is not a reason to stop working.

## Note

This command does not read the plan. It reads a few hundred bytes of manifest. Reading the plan itself is retrieval, which is what the Docs MCP is for.

Full mechanism: `plan-sync`.
