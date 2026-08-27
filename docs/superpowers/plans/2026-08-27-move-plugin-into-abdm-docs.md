# Move the plugin into abdm-docs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the `abdm-portal` plugin into `abdm-docs/.claude/plugin/` so it auto-loads for anyone who clones the repository it documents, leave this repository holding only the plan, and produce the drift audit that scopes the follow-up plan.

**Architecture:** The plugin stops describing a repository it cannot see and moves inside it. Checks that walked `plugin/` from this repository move to `abdm-docs`, where the files now are. This repository keeps the plan, `manifest.json` and the gantt, and the four plan compiled skills keep fetching that manifest over the network exactly as `plan-sync` already describes.

**Tech Stack:** Node 22 and npm in `abdm-docs`. POSIX shell in this repository. Claude Code plugin manifests. No new dependencies in either repository.

**Spec:** `docs/superpowers/specs/2026-08-27-portal-contributor-bible-design.md`

## Global Constraints

- No em dash, U+2014, anywhere in any file this plan touches, including commit messages and code comments. Use a full stop, a comma or a colon.
- New code is Node, not Python, to match `abdm-docs`. Stdlib and existing dependencies only. Do not add a package.
- Nothing parses an atom except `scripts/lib/atoms.mjs`. Any check needing atom frontmatter imports it.
- The plugin names no organisation as a class of author. `no Eka dependency` stays. `for the Eka support team` does not.
- Two repositories are in play. `PLAN_REPO` is `/Users/samdennis/code/abdm-ai-sandbox-plan`. `DOCS_REPO` is `/Users/samdennis/code/abdm-docs`. Every command below says which one it runs in.
- Work on a branch in each repository. In `PLAN_REPO` the branch is `feat/plan-reconcile-with-abdm-docs`, which already exists. In `DOCS_REPO` create `feat/plugin-as-bible`.
- Task 1 gates Task 2. Do not start Task 2 until Task 1's result is recorded.
- The spec's order of work runs the drift audit second, before the move. This
  plan runs it last, as Task 5. The reason is that after the move the plugin
  and the repository it describes are in one checkout, so every claim can be
  settled without switching directories. Nothing in Tasks 2 to 4 depends on the
  audit's findings, and nothing in Tasks 2 to 4 changes a claim the audit reads,
  because those tasks touch manifests, checks and READMEs rather than skill
  content. The one exception is the plugin README's skill count, corrected in
  Task 2 step 6, which is therefore already fixed when the audit runs.

---

### Task 1: Verify whether a project level settings.json auto-enables a plugin

The whole design assumes a contributor who clones `abdm-docs` gets the plugin loaded with no install step. That is unverified. This task answers it with evidence before anything is moved, because the answer changes Task 2.

**Files:**
- Create: `DOCS_REPO/.claude/AUTOLOAD-FINDING.md` (temporary, deleted in Task 2 once the finding is folded into the spec)

**Interfaces:**
- Consumes: nothing
- Produces: a recorded verdict, `AUTOLOAD_WORKS` true or false, which Task 2 branches on

- [ ] **Step 1: Build a throwaway fixture outside both repositories**

```bash
rm -rf /tmp/autoload-probe && mkdir -p /tmp/autoload-probe/.claude/plugin/.claude-plugin /tmp/autoload-probe/.claude/plugin/skills/probe-skill
cd /tmp/autoload-probe && git init -q
```

- [ ] **Step 2: Write a minimal plugin into the fixture**

```bash
cat > /tmp/autoload-probe/.claude/plugin/.claude-plugin/plugin.json <<'EOF'
{
  "name": "probe",
  "version": "0.0.1",
  "description": "Throwaway plugin used to verify project level auto-enable.",
  "license": "MIT"
}
EOF
cat > /tmp/autoload-probe/.claude/plugin/skills/probe-skill/SKILL.md <<'EOF'
---
name: probe-skill
description: Use only when someone asks to confirm the autoload probe loaded. Confirms a project level plugin was auto-enabled.
---

# Probe skill

If you can read this, a project level plugin auto-enabled.
EOF
```

- [ ] **Step 3: Declare and enable it from project level settings**

```bash
cat > /tmp/autoload-probe/.claude/settings.json <<'EOF'
{
  "extraKnownMarketplaces": {
    "probe-local": {
      "source": { "source": "directory", "path": "./.claude/plugin" }
    }
  },
  "enabledPlugins": { "probe@probe-local": true }
}
EOF
```

- [ ] **Step 4: Confirm the manifests are valid before drawing any conclusion**

Run, from `/tmp/autoload-probe`:

```bash
claude plugin validate ./.claude/plugin --strict
```

Expected: passes. If it fails, the fixture is wrong, not the mechanism. Fix the fixture and repeat before continuing.

- [ ] **Step 5: Start a session in the fixture and check what loaded**

Start Claude Code with `/tmp/autoload-probe` as the working directory, then run:

```bash
claude plugin list
```

Record whether `probe@probe-local` appears, and whether a trust prompt was shown first. Both facts matter. A plugin that loads only after the user accepts a prompt still satisfies the design, because the contributor is present at that moment. A plugin that never appears does not.

- [ ] **Step 6: Record the finding**

Write `DOCS_REPO/.claude/AUTOLOAD-FINDING.md` with: the exact `claude --version`, whether the plugin appeared in `claude plugin list`, whether a trust prompt appeared, and the verdict as a single line reading `AUTOLOAD_WORKS: true` or `AUTOLOAD_WORKS: false`.

Do not paraphrase the outcome. Paste the real output of `claude plugin list`. A verdict with no pasted evidence is not a verdict.

- [ ] **Step 7: Clean up the fixture**

```bash
rm -rf /tmp/autoload-probe
```

- [ ] **Step 8: Commit the finding**

```bash
cd /Users/samdennis/code/abdm-docs
git checkout -b feat/plugin-as-bible
git add .claude/AUTOLOAD-FINDING.md
git commit -m "Record whether a project level settings.json auto-enables a plugin"
```

---

### Task 2: Move the plugin into abdm-docs and wire it to load

**Files:**
- Create: `DOCS_REPO/.claude/plugin/` (the whole tree, moved from `PLAN_REPO/plugin/`)
- Create: `DOCS_REPO/.claude/settings.json`
- Modify: `DOCS_REPO/.claude/plugin/.claude-plugin/plugin.json` (homepage and repository)
- Modify: `DOCS_REPO/.claude/plugin/README.md` (install section, skill count)
- Delete: `DOCS_REPO/.claude/AUTOLOAD-FINDING.md` (its verdict moves into the spec)
- Delete: `PLAN_REPO/plugin/`

**Interfaces:**
- Consumes: `AUTOLOAD_WORKS` from Task 1
- Produces: `DOCS_REPO/.claude/plugin/` as the plugin's home, and either a working `settings.json` or a `.claude/skills/` copy, which Task 3's `bible.skills-copy` check depends on

- [ ] **Step 1: Move the tree with history preserved**

Run in `PLAN_REPO`:

```bash
cd /Users/samdennis/code/abdm-ai-sandbox-plan
git mv plugin /tmp/plugin-staging 2>/dev/null || cp -R plugin /tmp/plugin-staging
```

`git mv` cannot cross repositories, so this is a copy followed by a delete in Task 4. History for the plugin lives in `PLAN_REPO` up to this commit and continues in `DOCS_REPO` after it. Note the source commit SHA in the move commit message so the two halves can be joined by a reader.

```bash
git rev-parse HEAD
```

- [ ] **Step 2: Place it in abdm-docs**

```bash
cd /Users/samdennis/code/abdm-docs
mkdir -p .claude
cp -R /tmp/plugin-staging .claude/plugin
rm -rf /tmp/plugin-staging
```

- [ ] **Step 3: Correct the plugin manifest's own coordinates**

The plugin now lives in a different repository, so `homepage` and `repository` are wrong. Edit `.claude/plugin/.claude-plugin/plugin.json`, changing both values from `https://github.com/obadiah-1/abdm-ai-sandbox-plan` to `https://github.com/eka-care/abdm-docs`, and bump `version` from `0.2.0` to `0.3.0` because the install path changed.

- [ ] **Step 4: Validate before anything else**

```bash
cd /Users/samdennis/code/abdm-docs
claude plugin validate ./.claude/plugin --strict
```

Expected: passes. A malformed manifest fails the whole plugin rather than the part that is wrong, so nothing further in this task is meaningful until this passes.

- [ ] **Step 5: Wire the loading, branching on Task 1**

If `AUTOLOAD_WORKS: true`, create `DOCS_REPO/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "abdm-portal-local": {
      "source": { "source": "directory", "path": "./.claude/plugin" }
    }
  },
  "enabledPlugins": { "abdm-portal@abdm-portal-local": true }
}
```

If `AUTOLOAD_WORKS: false`, do not create that file. Instead copy the skills into the directory that is auto-discovered with certainty:

```bash
cd /Users/samdennis/code/abdm-docs
for d in .claude/plugin/skills/*/; do
  n=$(basename "$d")
  mkdir -p ".claude/skills/$n"
  cp -R "$d." ".claude/skills/$n/"
done
ls .claude/skills | wc -l
```

Expected: 18. Record in the commit message which branch was taken and why.

- [ ] **Step 6: Fix the plugin README's install section and skill count**

`.claude/plugin/README.md` tells the reader to add a marketplace and install. That is no longer how anyone gets it. Replace the Install section with the truth: the plugin lives in this repository and loads when you open it, and the fallback if it does not. Also correct `17 skills` to `18 skills`, which was already wrong before the move.

Verify the count rather than trusting either number:

```bash
ls .claude/plugin/skills | wc -l
ls .claude/plugin/agents | wc -l
ls .claude/plugin/commands | wc -l
```

Expected: 18, 6, 12. Write whatever these actually print.

- [ ] **Step 7: Confirm no skill shares a name with a command**

This rule was enforced by `PLAN_REPO` CI and has no home yet. Check it by hand now, and Task 3 makes it permanent.

```bash
cd /Users/samdennis/code/abdm-docs
comm -12 <(ls .claude/plugin/skills | sort) <(ls .claude/plugin/commands | sed 's/\.md$//' | sort)
```

Expected: no output. Any name printed means one component shadows the other.

- [ ] **Step 8: Fold the autoload finding into the spec and delete the temporary file**

Copy the verdict and the pasted evidence into the spec's section 2, replacing the paragraph that begins "This is the one unverified assumption in the design", then:

```bash
rm .claude/AUTOLOAD-FINDING.md
```

- [ ] **Step 9: Commit**

```bash
cd /Users/samdennis/code/abdm-docs
git add .claude
git commit -m "Move the abdm-portal plugin into .claude/plugin

The plugin describes this repository, so it now lives inside it. A
contributor who clones this repo gets the rules without installing
anything.

Moved from obadiah-1/abdm-ai-sandbox-plan at <SOURCE SHA FROM STEP 1>.
History for the plugin continues here from that commit."
```

---

### Task 3: Give the moved checks a home in abdm-docs

Two checks in `PLAN_REPO/scripts/plan-check.sh` walk `plugin/`: the `plan_version` stamp on each compiled skill, and every `plan#<id>` citation. After Task 2 there is no `plugin/` there to walk, so both would silently pass on nothing. They move here.

This is the first task with real code, so it is test first.

**Files:**
- Create: `DOCS_REPO/scripts/check-plan-stamp.mjs`
- Create: `DOCS_REPO/scripts/check-plan-stamp.test.mjs`
- Modify: `DOCS_REPO/package.json` (add the script and a test entry)
- Modify: `DOCS_REPO/.github/workflows/ci.yml` (add the job)

**Interfaces:**
- Consumes: `.claude/plugin/skills/*/SKILL.md` frontmatter, and `manifest.json` fetched from `PLAN_REPO`'s raw URL
- Produces: `npm run check:plan-stamp`, exit 0 or 1. Task 5 of the follow-up plan absorbs this file into `check-bible.mjs` rather than duplicating it

- [ ] **Step 1: Write the failing test**

Create `DOCS_REPO/scripts/check-plan-stamp.test.mjs`. It uses the Node built in test runner, which needs no dependency.

```javascript
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { checkStamps, checkCitations } from './check-plan-stamp.mjs';

test('a skill stamped with the manifest version passes', () => {
  const skills = [{ name: 'portal-architecture', plan_version: '2026.08.25' }];
  const problems = checkStamps(skills, '2026.08.25');
  assert.deepEqual(problems, []);
});

test('a skill stamped with an older version fails and names both versions', () => {
  const skills = [{ name: 'portal-architecture', plan_version: '2026.08.24' }];
  const problems = checkStamps(skills, '2026.08.25');
  assert.equal(problems.length, 1);
  assert.match(problems[0], /portal-architecture/);
  assert.match(problems[0], /2026\.08\.24/);
  assert.match(problems[0], /2026\.08\.25/);
});

test('a skill with no plan_version is ignored, because only compiled skills carry one', () => {
  const skills = [{ name: 'writing-guide', plan_version: undefined }];
  assert.deepEqual(checkStamps(skills, '2026.08.25'), []);
});

test('a cited plan id that the plan defines passes', () => {
  const planText = '<a id="p4-skills"></a>\n## Skills';
  assert.deepEqual(checkCitations(['p4-skills'], planText), []);
});

test('a cited plan id the plan does not define fails and names the id', () => {
  const problems = checkCitations(['p9-ghost'], '<a id="p4-skills"></a>');
  assert.equal(problems.length, 1);
  assert.match(problems[0], /p9-ghost/);
});
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/samdennis/code/abdm-docs
node --test scripts/check-plan-stamp.test.mjs
```

Expected: FAIL, with an error resolving `./check-plan-stamp.mjs`.

- [ ] **Step 3: Write the implementation**

Create `DOCS_REPO/scripts/check-plan-stamp.mjs`:

```javascript
// The plan lives in obadiah-1/abdm-ai-sandbox-plan and this plugin compiles
// from it. These two checks used to run there, walking plugin/. The plugin
// moved here, so they run here, against the manifest the plan publishes.
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const PLUGIN = join(root, '.claude', 'plugin');
const MANIFEST_URL =
  'https://raw.githubusercontent.com/obadiah-1/abdm-ai-sandbox-plan/main/manifest.json';
const PLAN_URL =
  'https://raw.githubusercontent.com/obadiah-1/abdm-ai-sandbox-plan/main/abdm-v1-phase1-architecture-and-plan.md';

export function checkStamps(skills, wantVersion) {
  const problems = [];
  for (const s of skills) {
    if (s.plan_version === undefined) continue;
    if (s.plan_version !== wantVersion) {
      problems.push(
        `${s.name} is stamped plan_version ${s.plan_version}, the published plan is ${wantVersion}. Recompile it from the plan and restamp.`
      );
    }
  }
  return problems;
}

export function checkCitations(ids, planText) {
  const problems = [];
  for (const id of ids) {
    if (!planText.includes(`<a id="${id}"></a>`)) {
      problems.push(
        `plan#${id} is cited in the plugin but the plan defines no section with that id.`
      );
    }
  }
  return problems;
}

export function readSkills() {
  const dir = join(PLUGIN, 'skills');
  if (!existsSync(dir)) return [];
  return readdirSync(dir).flatMap((name) => {
    const file = join(dir, name, 'SKILL.md');
    if (!existsSync(file)) return [];
    const raw = readFileSync(file, 'utf8');
    const m = raw.match(/^plan_version:\s*(\S+)\s*$/m);
    return [{ name, plan_version: m ? m[1] : undefined }];
  });
}

export function citedIds() {
  const found = new Set();
  const walk = (d) => {
    for (const e of readdirSync(d, { withFileTypes: true })) {
      const p = join(d, e.name);
      if (e.isDirectory()) walk(p);
      else if (e.name.endsWith('.md') || e.name.endsWith('.json')) {
        for (const m of readFileSync(p, 'utf8').matchAll(/plan#([a-z0-9.-]*[a-z0-9])/g)) {
          found.add(m[1]);
        }
      }
    }
  };
  if (existsSync(PLUGIN)) walk(PLUGIN);
  return [...found];
}

// Only run the network half when invoked directly, so the tests stay offline.
if (import.meta.url === `file://${process.argv[1]}`) {
  let manifest;
  let planText;
  try {
    manifest = await (await fetch(MANIFEST_URL)).json();
    planText = await (await fetch(PLAN_URL)).text();
  } catch (e) {
    console.error(`Could not reach the published plan: ${e.message}`);
    console.error('This check needs the network. It fails rather than passing quietly.');
    process.exit(1);
  }

  const problems = [
    ...checkStamps(readSkills(), manifest.plan_version),
    ...checkCitations(citedIds(), planText),
  ];

  if (problems.length) {
    console.error(`${problems.length} problem(s):`);
    for (const p of problems) console.error('  ' + p);
    process.exit(1);
  }
  console.log(`All plan stamps match plan_version ${manifest.plan_version}.`);
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/samdennis/code/abdm-docs
node --test scripts/check-plan-stamp.test.mjs
```

Expected: PASS, 5 tests.

- [ ] **Step 5: Run the real check against the real plugin**

```bash
cd /Users/samdennis/code/abdm-docs
node scripts/check-plan-stamp.mjs
```

Expected: `All plan stamps match plan_version 2026.08.25.` If it fails naming a skill, that is a genuine finding. Record it for the audit in Task 5 and do not edit the skill to silence it.

- [ ] **Step 6: Add the npm scripts**

In `DOCS_REPO/package.json`, inside `scripts`, add:

```json
"check:plan-stamp": "node scripts/check-plan-stamp.mjs",
"test:scripts": "node --test scripts/*.test.mjs"
```

- [ ] **Step 7: Add the CI job**

In `DOCS_REPO/.github/workflows/ci.yml`, add a job alongside the existing ones, matching their shape exactly:

```yaml
  plan-stamp:
    name: Plugin is built from the current plan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run test:scripts
      - run: npm run check:plan-stamp
      - name: No skill shares a name with a command
        run: |
          dupes=$(comm -12 <(ls .claude/plugin/skills | sort) <(ls .claude/plugin/commands | sed 's/\.md$//' | sort))
          if [ -n "$dupes" ]; then echo "name collision: $dupes"; exit 1; fi
          echo "ok no collisions"
```

- [ ] **Step 8: Commit**

```bash
cd /Users/samdennis/code/abdm-docs
git add scripts/check-plan-stamp.mjs scripts/check-plan-stamp.test.mjs package.json .github/workflows/ci.yml
git commit -m "Check plan stamps and plan#id citations here, where the plugin now lives

These two checks ran in the plan repo against plugin/. That directory
moved, so they moved with it. The plan is still fetched over the
network from its published manifest, unchanged."
```

---

### Task 4: Make this repository plan only

**Files:**
- Delete: `PLAN_REPO/plugin/`
- Modify: `PLAN_REPO/scripts/plan-check.sh` (drop sections 2 and 4)
- Modify: `PLAN_REPO/.claude-plugin/marketplace.json`
- Modify: `PLAN_REPO/.github/workflows/checks.yml`
- Modify: `PLAN_REPO/README.md`

**Interfaces:**
- Consumes: Task 2 having landed the plugin in `DOCS_REPO`
- Produces: a repository holding the plan, `manifest.json`, the gantt and the plan gate only

- [ ] **Step 1: Confirm the plugin is safely landed before deleting anything**

```bash
cd /Users/samdennis/code/abdm-docs
git log --oneline -1 -- .claude/plugin && ls .claude/plugin/skills | wc -l
```

Expected: a commit from Task 2, and 18. Do not proceed on anything less.

- [ ] **Step 2: Delete the plugin from this repository**

```bash
cd /Users/samdennis/code/abdm-ai-sandbox-plan
git rm -r -q plugin
```

- [ ] **Step 3: Drop the two checks that no longer have anything to walk**

In `scripts/plan-check.sh`, delete section 2, the loop over `compiled_skills` reading `plugin/skills/$s/SKILL.md`, and section 4, the loop over `plan#` citations that greps `plugin/`. Keep sections 1, 3 and 5, which are the plan hash, the gantt stamp and `plan-history/`.

Section 4 greps `plugin/ gantt/`. The `gantt/` half still applies, so keep the citation check with `plugin/` removed from the grep target rather than deleting it whole:

```sh
for id in $(grep -rho 'plan#[a-z0-9.-]*' gantt/ | sed -e 's/^plan#//' -e 's/\.$//' | sort -u); do
```

Add a comment above the deleted section 2 saying where it went, so the next reader does not think it was dropped:

```sh
# The compiled skill stamps are checked in eka-care/abdm-docs, at
# scripts/check-plan-stamp.mjs, because the plugin lives there now. That check
# fetches this repository's manifest.json.
```

- [ ] **Step 4: Run the gate and confirm it still passes**

```bash
cd /Users/samdennis/code/abdm-ai-sandbox-plan
./scripts/plan-check.sh
```

Expected: `ok` on the plan hash, the gantt stamp and `plan-history/`, and exit 0. No line mentioning a skill.

- [ ] **Step 5: Point the marketplace at the new home**

`.claude-plugin/marketplace.json` lists a plugin at `./plugin`, which no longer exists, so anyone installing from this marketplace gets a broken install. Change the entry's `source` to the git source of the new home so existing installs update to the right place rather than failing:

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "abdm-portal",
  "description": "The ABDM Developer Portal plan. The plugin it compiles into now lives in eka-care/abdm-docs.",
  "owner": {
    "name": "ABDM Developer Portal working group",
    "url": "https://github.com/obadiah-1/abdm-ai-sandbox-plan"
  },
  "plugins": [
    {
      "name": "abdm-portal",
      "source": {
        "source": "github",
        "repo": "eka-care/abdm-docs",
        "path": ".claude/plugin"
      },
      "description": "Build and operate the ABDM Developer Portal. Lives in eka-care/abdm-docs, where the content it describes lives. Cloning that repository loads it without an install.",
      "category": "documentation",
      "homepage": "https://github.com/eka-care/abdm-docs"
    }
  ]
}
```

Then validate, because a malformed marketplace fails everything:

```bash
claude plugin validate .claude-plugin/marketplace.json --strict
```

Expected: passes. If the schema rejects a `path` inside a github source, drop the plugins array entirely and leave the marketplace with an empty list plus the description saying where the plugin went. Record which of the two you did.

- [ ] **Step 6: Drop the CI jobs that walked the plugin**

In `.github/workflows/checks.yml`, delete the `plugin-validate` job entirely. It validates `./plugin`, runs the agent frontmatter check and the name collision check, all against files that are no longer here. Keep the `plan-check` job.

Also delete `scripts/check-agent-frontmatter.py`, which only ever checked `plugin/agents/`.

```bash
cd /Users/samdennis/code/abdm-ai-sandbox-plan
git rm -q scripts/check-agent-frontmatter.py
```

Note in the commit message that the agent frontmatter check is now covered by `claude plugin validate` in `DOCS_REPO`, so it is not lost.

- [ ] **Step 7: Rewrite the README for a plan only repository**

`README.md` currently opens with "Everything for the ABDM Developer Portal V1 in one place" and carries an install section, a twelve command table and a "Working on the plugin" section. All of that is now wrong. Rewrite so it says: this repository holds the plan, its history and the manifest that installed plugins check themselves against, and the plugin lives in `eka-care/abdm-docs` under `.claude/plugin`. Keep the "Changing the plan" section, correcting step 3 to say the compiled skills live in the other repository and that its CI enforces the stamp.

- [ ] **Step 8: Run the gate one more time and commit**

```bash
cd /Users/samdennis/code/abdm-ai-sandbox-plan
./scripts/plan-check.sh && git add -A && git commit -m "Become plan only, the plugin lives in abdm-docs now

The plugin moved to eka-care/abdm-docs under .claude/plugin, where the
content it describes lives. The stamp and citation checks moved with it.
This repo keeps the plan, its history, the manifest installed plugins
check against, and the gantt.

The agent frontmatter check is dropped here and covered by
claude plugin validate in abdm-docs."
```

---

### Task 5: Audit every plugin claim against the repository

The spec's drift table came from sampling, not from a pass. This task produces the real list, and its output is what scopes the follow-up plan. It changes no plugin content: finding and fixing are separate so the fixes can be reviewed against a written list rather than against someone's memory.

**Files:**
- Create: `DOCS_REPO/.claude/plugin/DRIFT-AUDIT-2026-08-27.md`

**Interfaces:**
- Consumes: the plugin at `.claude/plugin`, and the live repository around it
- Produces: a table of every false claim, which becomes the task list of the follow-up plan

- [ ] **Step 1: Extract every checkable claim from the plugin**

Go through all 18 skills, 6 agents and 12 commands. A claim is checkable when it names a path, a filename, an enum value, a numeric limit, a required field, a section heading, a command, a count, or a scope statement such as out of scope or not written. Ignore claims of judgement, which the audit cannot settle.

Record each as a row: where it is stated, file and line, and what it asserts.

- [ ] **Step 2: Check each claim against the repository, naming your evidence**

For each row, find the file in `abdm-docs` that settles it and record that path and line as the evidence. Sources that settle a claim:

| Claim about | Settled by |
| --- | --- |
| Atom fields, enums, statuses, sections, folders | `scripts/lint-atoms.mjs` |
| Page limits, budgets, banned headings | `scripts/lint-content.mjs` |
| Spec facets, operationId rules | `scripts/lint-agent-readiness.mjs`, `catalogue/openapi/CONVENTIONS.md` |
| Where files live, what renders | `CONTRIBUTING.md`, the live tree |
| What the indexer does | `catalogue/README.md`, `mcp/cmd/indexer` |
| What CI enforces | `.github/workflows/ci.yml`, `package.json` |
| Counts | `ls` and `wc`, run, not estimated |

A claim with no evidence found is recorded as `unsettled`, not as correct. Guessing at this step is the failure mode that produced the drift.

- [ ] **Step 3: Write the audit file**

Write `.claude/plugin/DRIFT-AUDIT-2026-08-27.md` with one table:

| Skill | Line | Claim | Reality | Evidence | Verdict |

`Verdict` is one of `true`, `false`, `misleading` or `unsettled`. Use `misleading` for a claim that is literally true and reads false in context. The NHCX rule is the example: atoms genuinely reject `gateway: nhcx`, and a reader concludes NHCX does not exist while editing `site/docs/nhcx/`.

- [ ] **Step 4: Summarise at the top of the file**

Above the table, write the counts by verdict, and list the claims that would cause a contributor's first pull request to be rejected. That subset is the priority order for the follow-up plan.

- [ ] **Step 5: State the audit's own limits**

Below the summary, write what the audit did not cover and why: judgement claims, anything in the four plan compiled skills, which are checked against the plan rather than the repository, and any area where you found no evidence either way. An audit that does not say where it stopped invites the reader to assume it stopped nowhere.

- [ ] **Step 6: Commit**

```bash
cd /Users/samdennis/code/abdm-docs
git add .claude/plugin/DRIFT-AUDIT-2026-08-27.md
git commit -m "Audit every checkable plugin claim against this repository

Finding only, no fixes. The verdict counts and the rejection causing
subset scope the follow-up plan."
```

---

## What this plan does not do

Named here so the gap is deliberate rather than forgotten. All of it is the follow-up plan, which cannot be written in bite-sized tasks until Task 5 says what is actually wrong.

- Fixing the drift the audit finds
- `page-authoring`, the new skill covering `site/docs` content rules
- Re-aiming `atom-authoring`, `openapi-ingest`, `catalogue-linting`, `docs-ux`, `abdm-portal-index`, `support-agent` and `portal-planning`
- `check-bible.mjs` and the four rules folded into the existing checks
- `AGENTS.md` and the `CLAUDE.md` symlink

Until `AGENTS.md` lands, a contributor who does not load the plugin is guarded by the seven existing checks and nothing else. That is the same position as today, so this plan makes nothing worse, but it does not yet make that better.
