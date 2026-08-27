# Re-aim the plugin at the repository Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every claim the `abdm-portal` plugin makes true against `abdm-docs` as it actually is, cover the two things it never covered, and make the em dash rule enforced rather than merely asserted.

**Architecture:** The plugin moved inside `abdm-docs` in the previous plan and an audit found 18 false and 9 misleading claims out of 36. That audit is this plan's requirements document. Four skills compile from a plan in another repository, and the plan's own scope statements are stale, so those are corrected at the source and recompiled rather than hand edited.

**Tech Stack:** Node 22 and npm in `abdm-docs`. POSIX shell and Python in the plan repository, for files that already use them. No new dependencies.

**Spec:** `docs/superpowers/specs/2026-08-27-portal-contributor-bible-design.md`

**Requirements document:** `.claude/plugin/DRIFT-AUDIT-2026-08-27.md` in `abdm-docs`. Every row verdicted `false` or `misleading` is work. The Absences section is work. Rows verdicted `true` are not. Rows verdicted `unsettled` are settled or left with their reason recorded, never quietly marked true.

## Global Constraints

- No em dash, U+2014, anywhere in any file this plan touches, including commit messages and code comments. Use a full stop, a comma or a colon. Task 4 makes this mechanical, so from Task 4 onward a violation fails CI rather than review.
- New code is Node, not Python, in `abdm-docs`. Stdlib and existing dependencies only. Do not add a package.
- Nothing parses an atom except `scripts/lib/atoms.mjs`.
- The plugin names no organisation as a class of author. `no Eka dependency` stays as a constraint. `for the Eka support team` does not.
- Repositories. `PLAN_REPO` is `/Users/samdennis/code/abdm-ai-sandbox-plan` on branch `feat/plan-reconcile-with-abdm-docs`. `DOCS_REPO` is the worktree `/private/tmp/claude-502/-Users-samdennis-code-abdm-ai-sandbox-plan/0919c9e0-c6eb-4c2c-aa92-cc6b2d65d962/scratchpad/bible-wt` on branch `feat/plugin-as-bible`. Never touch `/Users/samdennis/code/abdm-docs`, which holds someone else's uncommitted work.
- Two copies of every skill exist, at `.claude/plugin/skills/` and `.claude/skills/`. `.claude/plugin/` is the source. Every skill edit must be mirrored, and CI fails if they diverge. Task 1 extends that rule to commands and agents.
- Never set a `verified` status, never edit a file carrying `generated: true`, never edit anything under `catalogue/openapi/.raw/`, which is upstream NHA content stored untouched.

---

### Task 1: Make the plugin actually load, and make the claim about it true

`CONTRIBUTING.md` says opening the repository loads the plugin with no install step. Skills do load, because `.claude/skills/` is auto-discovered. Commands and agents do not, because they live at `.claude/plugin/commands/` and `.claude/plugin/agents/`, which is not a discovered path, and the plugin install route through `.claude/settings.json` does not work. The sentence is false as shipped.

**Files:**
- Create: `DOCS_REPO/.claude/commands/` (12 files, copied)
- Create: `DOCS_REPO/.claude/agents/` (6 files, copied)
- Modify: `DOCS_REPO/.github/workflows/ci.yml` (extend the existing copy guard)
- Modify: `DOCS_REPO/CONTRIBUTING.md`
- Modify: `DOCS_REPO/.claude/plugin/README.md`

**Interfaces:**
- Consumes: the plugin at `.claude/plugin`, and the skills copy guard already in the `plan-stamp` job
- Produces: three mirrored directories under `.claude/`, and one guard covering all three

- [ ] **Step 1: Confirm the three discovered directories and what is missing**

```bash
cd /private/tmp/claude-502/-Users-samdennis-code-abdm-ai-sandbox-plan/0919c9e0-c6eb-4c2c-aa92-cc6b2d65d962/scratchpad/bible-wt
ls .claude/
ls .claude/plugin/commands | wc -l
ls .claude/plugin/agents | wc -l
```

Expected: `.claude/` holds `skills` but neither `commands` nor `agents`, and the plugin holds 12 and 6.

- [ ] **Step 2: Mirror commands and agents**

```bash
mkdir -p .claude/commands .claude/agents
cp .claude/plugin/commands/*.md .claude/commands/
cp -R .claude/plugin/agents/. .claude/agents/
ls .claude/commands | wc -l
ls .claude/agents | wc -l
```

Expected: 12 and 6. Real copies, not symlinks, for the same reason the skills copy is real: whether a symlinked component directory is followed is unverified, and it fails silently.

- [ ] **Step 3: Extend the copy guard to all three directories**

The `plan-stamp` job in `.github/workflows/ci.yml` already carries a step comparing `.claude/plugin/skills` against `.claude/skills`, excluding `README.md`. Extend it to compare commands and agents too. Keep the `README.md` exclusion, which exists because `.claude/skills/README.md` has no counterpart. Do not add `|| true`.

- [ ] **Step 4: Prove the guard fails, for each of the three directories**

For each of skills, commands and agents: run the step and see it pass, append one byte to a file in the plugin copy, run it and see it fail naming that file, restore, run it and see it pass. Paste all nine runs. A guard nobody has watched fail is not a guard, and a guard extended to two new directories has two new chances to be vacuous.

- [ ] **Step 5: Correct the CONTRIBUTING claim**

The section added in the previous plan says the plugin "loads it automatically, no install step needed". Rewrite it to say what is true: opening the repository in Claude Code gives you the skills, the commands and the agents, because they sit in the directories Claude Code discovers, and no install step is needed. Say plainly that `.claude/plugin/` is the source of all three and that the copies are generated and guarded by CI, so a contributor edits the plugin copy and never the mirror.

Do not describe `.claude/settings.json` as the mechanism. It is present and does not currently take effect.

- [ ] **Step 6: Correct the plugin README the same way**

It carries a hedge about auto-loading. Replace the hedge with the same true statement.

- [ ] **Step 7: Verify the mirrors are byte identical and commit**

```bash
diff -r .claude/plugin/skills .claude/skills -x README.md && echo "skills ok"
diff -r .claude/plugin/commands .claude/commands && echo "commands ok"
diff -r .claude/plugin/agents .claude/agents && echo "agents ok"
git add -A .claude CONTRIBUTING.md .github/workflows/ci.yml
git commit -m "Mirror commands and agents into the directories Claude Code discovers

Skills loaded on clone. Commands and agents did not, because they sat only
inside .claude/plugin, which is reachable by installing the plugin, and the
project level install does not take effect. CONTRIBUTING claimed otherwise.

The copy guard now covers all three directories."
```

---

### Task 2: Correct the plan's scope, recompile the four skills it produces

The plan says NHCX is out of scope and HIE-CM M4 is Phase 2 with nothing written. The repository has `catalogue/nhcx/`, `site/docs/nhcx/`, `catalogue/openapi/nhcx/v1/`, `hiecm-m4.yaml`, `hiecm-p1.yaml` through `p3`, and `hiecm-phr-services.yaml`. The four plan-compiled skills repeat the plan's version, so the fix belongs in the plan, not in the skills. Hand editing them is overwritten on the next compile, silently.

This task spans both repositories and is the only one that touches the plan.

**Files:**
- Modify: `PLAN_REPO/abdm-v1-phase1-architecture-and-plan.md` (scope sections only)
- Create: `PLAN_REPO/plan-history/plan-2026.08.25.md`
- Modify: `PLAN_REPO/manifest.json`
- Modify: `PLAN_REPO/gantt/build_gantt.py` (`PLAN_VERSION` only, unless the schedule changed)
- Modify: `DOCS_REPO/.claude/plugin/skills/{portal-architecture,portal-planning,dpg-governance,abdm-portal-index}/SKILL.md` and their `.claude/skills/` mirrors

**Interfaces:**
- Consumes: the audit's rows against `abdm-portal-index`'s gateway and phase table
- Produces: a new `plan_version`, and four skills restamped to it. `scripts/check-plan-stamp.mjs` in DOCS_REPO goes green once the plan repository branch merges, and not before

- [ ] **Step 1: Establish what the repository actually contains, before editing prose about it**

```bash
cd /private/tmp/claude-502/-Users-samdennis-code-abdm-ai-sandbox-plan/0919c9e0-c6eb-4c2c-aa92-cc6b2d65d962/scratchpad/bible-wt
find catalogue/openapi -name '*.yaml' -not -path '*/.raw/*' | sort
ls site/docs/
for g in hiecm nhcx uhi shared; do echo "$g: $(find catalogue/$g -name '*.md' | wc -l) atoms"; done
grep -rn 'nhcx' scripts/lint-atoms.mjs
```

Write down what each command printed. The prose you write in step 3 must match these outputs and nothing else.

- [ ] **Step 2: Archive the plan version you are about to replace**

```bash
cd /Users/samdennis/code/abdm-ai-sandbox-plan
cp abdm-v1-phase1-architecture-and-plan.md plan-history/plan-2026.08.25.md
```

- [ ] **Step 3: Correct the plan's scope statements**

Edit only the sections that make scope claims. The correction has to hold a distinction the old text collapsed, and getting this wrong reintroduces the audit's `misleading` verdict in a new form:

- NHCX is rejected for **atoms**. `scripts/lint-atoms.mjs` hard fails `gateway: nhcx` and its `GATEWAYS` list is `hiecm`, `uhi`, `shared`. That is deliberate and stays.
- NHCX is **live** for site pages and specs. `site/docs/nhcx/` renders, `catalogue/openapi/nhcx/v1/` exists, and `CONTRIBUTING.md` documents provider and payer roles.
- Say both, in the same paragraph, and say which is enforced where. A reader must not be able to conclude either that NHCX does not exist or that they may write NHCX atoms.

For M4 and the `p1` to `p3` and `phr-services` modules: the specifications exist and render. Say what exists, and separately say what is verified, which is a different claim. Do not upgrade anything to verified.

- [ ] **Step 4: Bump the manifest**

Compute the hash and set `plan_version` to today's date in the documented format, with a counter if a version already exists for today.

```bash
cd /Users/samdennis/code/abdm-ai-sandbox-plan
shasum -a 256 abdm-v1-phase1-architecture-and-plan.md
```

Set `plan_hash` to that value with the `sha256:` prefix. Set `breaking: true`, because a scope statement changed and scope is a principle.

- [ ] **Step 5: Restamp the gantt generator**

Update `PLAN_VERSION` in `gantt/build_gantt.py`. Only touch the `TASKS` table if step 3 changed the schedule, which it should not have.

- [ ] **Step 6: Run the plan gate**

```bash
./scripts/plan-check.sh
```

Expected: exits 0. If it fails, it names what is behind. Fix that, do not weaken the gate.

- [ ] **Step 7: Recompile the four skills**

There is no automated compiler for these four in this repository, so this is a careful hand rebuild followed by a restamp, which is what `plan-sync` describes. For each of `portal-architecture`, `portal-planning`, `dpg-governance` and `abdm-portal-index`:

1. Update the content that derives from the sections you changed in step 3
2. Set `plan_version` and `plan_hash` in the frontmatter to the new values
3. Mirror the file into `.claude/skills/<name>/SKILL.md`

`abdm-portal-index` also carries the gateway and phase table the audit checked directly. Correct that table against step 1's real output.

- [ ] **Step 8: Verify both repositories**

```bash
./scripts/plan-check.sh
cd /private/tmp/claude-502/-Users-samdennis-code-abdm-ai-sandbox-plan/0919c9e0-c6eb-4c2c-aa92-cc6b2d65d962/scratchpad/bible-wt
diff -r .claude/plugin/skills .claude/skills -x README.md && echo "mirror ok"
node scripts/check-plan-stamp.mjs
```

`check-plan-stamp.mjs` will still fail, because it fetches the manifest published on `main` and your bump is on an unmerged branch. Confirm the failure now names the NEW version as the one the skills carry, which proves the restamp landed. Paste it.

- [ ] **Step 9: Commit in both repositories, separately**

---

### Task 3: Rewrite catalogue-linting from the checks that actually run

The skill documents about thirty rules with dotted identifiers: `schema.required`, `graph.skills-exist`, `prose.no-em-dash`, `compile.identifier-diff`. No script emits a dotted rule id. A contributor whose build is red will search for the identifier the skill names and find nothing. This is the largest single false claim in the plugin.

**Files:**
- Modify: `DOCS_REPO/.claude/plugin/skills/catalogue-linting/SKILL.md` and its mirror

**Interfaces:**
- Consumes: the seven checks in `package.json` and the jobs in `.github/workflows/ci.yml`
- Produces: a rule reference whose every failure message is one a contributor will really see

- [ ] **Step 1: Enumerate what actually runs**

```bash
cd /private/tmp/claude-502/-Users-samdennis-code-abdm-ai-sandbox-plan/0919c9e0-c6eb-4c2c-aa92-cc6b2d65d962/scratchpad/bible-wt
sed -n '/"scripts"/,/}/p' package.json
grep -n 'name:' .github/workflows/ci.yml
```

- [ ] **Step 2: Extract the real failure messages from each script**

For each of `lint-atoms.mjs`, `lint-content.mjs`, `lint-agent-readiness.mjs`, `lint-tables.mjs`, `check-source-freshness.mjs`, `validate-skills.mjs` and `check-plan-stamp.mjs`, read the script and record every string it can fail with, verbatim, with its file and line.

Spectral is different: `lint:specs` runs Spectral over `catalogue/openapi/*/*/*.yaml` with `--fail-severity=error`, and its rules come from `.spectral.yaml`. Read that file and record the ruleset rather than inventing rule names.

- [ ] **Step 3: Rewrite the skill**

Structure it by the npm script a contributor runs, because that is how a failure reaches them. For each script: what it covers, what it fails on, the verbatim message, and the fix. Where a message is produced with a template, show the template and one real example.

Delete every dotted rule identifier. Do not replace one invented naming scheme with another. If a rule genuinely has no name, refer to it by its message.

Keep the section on what to do when a rule seems wrong. It is one of the few parts of this skill that was true, and it says the right thing: fix the content, or fix the rule and add a case, never weaken a rule to green a build.

- [ ] **Step 4: Verify every message you wrote appears in a script**

For each verbatim message in your rewritten skill, grep the scripts for it and confirm a hit. Paste the count of messages documented and the count found. They must be equal. This is the check that stops this skill drifting the same way twice.

- [ ] **Step 5: Mirror, then commit**

---

### Task 4: Make the em dash rule enforced everywhere it is claimed

Three scripts enforce it: `lint-atoms.mjs:79` over atoms, `lint-content.mjs:205` over page bodies, `validate-skills.mjs:43` over compiled skills. The plugin claims the rule holds everywhere including code comments and commit messages. It does not hold over `site/src/`, `mcp/`, `scripts/`, the authored spec YAMLs, or any commit message.

**Files:**
- Modify: `DOCS_REPO/.github/workflows/ci.yml`
- Modify: `DOCS_REPO/.claude/plugin/skills/writing-guide/SKILL.md` and its mirror

**Interfaces:**
- Consumes: nothing
- Produces: a CI step failing on U+2014 in any authored file

- [ ] **Step 1: Establish the real current state**

```bash
cd /private/tmp/claude-502/-Users-samdennis-code-abdm-ai-sandbox-plan/0919c9e0-c6eb-4c2c-aa92-cc6b2d65d962/scratchpad/bible-wt
git grep -l $'—' -- . ':!node_modules'
```

Every hit is one of three kinds and you must classify each before writing the check:
- `catalogue/openapi/.raw/` and the postman collection: upstream NHA files stored untouched. Exempt by convention, never edited.
- `scripts/lint-atoms.mjs`, `scripts/lint-content.mjs`, `scripts/validate-skills.mjs`: these contain the character because they search for it. Exempt.
- Anything else: a real violation to fix.

- [ ] **Step 2: Fix the real violations**

Replace each with a full stop, a comma or a colon, choosing by what the sentence is doing. Do not delete the punctuation and leave a run on sentence.

- [ ] **Step 3: Add the CI step**

Add to the `plan-stamp` job. Use `git grep`, which respects tracked files and needs no dependency:

```yaml
      - name: No em dash anywhere authored
        run: |
          if git grep -l $'—' -- . ':!node_modules' ':!catalogue/openapi/.raw' \
               ':!scripts/lint-atoms.mjs' ':!scripts/lint-content.mjs' ':!scripts/validate-skills.mjs'; then
            echo "em dash found in the files above. Use a full stop, a comma or a colon."
            exit 1
          fi
          echo "ok no em dash"
```

Confirm the exclusion syntax works in the runner's git before relying on it. If `git grep` pathspec exclusions behave differently there, use a `find` and `grep` pipeline instead, and say why you changed it.

- [ ] **Step 4: Prove it fails**

Add a U+2014 to one authored file, run the step, see it fail naming that file, remove it, run it again, see it pass. Paste all three.

- [ ] **Step 5: Correct the writing-guide skill**

It states the rule as absolute. That is now true for authored files, so say where it is enforced and name the two exemptions and why each exists. An exemption a contributor cannot see looks like the rule failing.

Commit messages are still not covered, because CI sees a squashed history. Say that plainly rather than implying coverage.

- [ ] **Step 6: Mirror, then commit**

---

### Task 5: Write page-authoring

Nothing in the plugin covers `site/docs` pages. `CONTRIBUTING.md` carries a 242 line content paradigm that binds every page, and an agent generating documentation has no skill telling it any of this. This is half of what contributors actually produce.

**Files:**
- Create: `DOCS_REPO/.claude/plugin/skills/page-authoring/SKILL.md` and its mirror
- Modify: `DOCS_REPO/.claude/plugin/skills/abdm-portal-index/SKILL.md` and its mirror (route to it)

**Interfaces:**
- Consumes: `CONTRIBUTING.md`, and the real constants in `scripts/lint-content.mjs`
- Produces: a skill an agent loads before writing any page under `site/docs`

- [ ] **Step 1: Read the source, and take the numbers from the code not the prose**

```bash
cd /private/tmp/claude-502/-Users-samdennis-code-abdm-ai-sandbox-plan/0919c9e0-c6eb-4c2c-aa92-cc6b2d65d962/scratchpad/bible-wt
sed -n '24,40p' scripts/lint-content.mjs
```

That block holds `TYPES`, `SENTENCE_WARN`, `SENTENCE_ERROR`, `PARAGRAPH_SENTENCES`, `IN_SHORT_ABOVE`, `DESCRIPTION_MAX` and `BUDGET_ERROR_FACTOR`. Where `CONTRIBUTING.md` and the code disagree, the code wins and you record the disagreement as a finding in your report.

- [ ] **Step 2: Write the skill**

Follow the shape of `atom-authoring`, which is the plugin's best existing skill of this kind: what to answer before writing, the mandatory frontmatter, the structure, the common mistakes table.

Cover, at minimum: where a page goes in the tree and that the tree is the navigation; `sidebar_position` and `_category_.json`; the mandatory `description` and its limit; when `## In short` is required and when it is banned; that Introduction and Overview are rejected as a first heading; the six questions every page answers; the word budgets per page type and that the fix for an over budget page is to split it, never to compress the prose; the sentence and paragraph limits with which tier each is; roles as a facet declared in frontmatter rather than a folder; and that pages carrying `generated: true` are never hand edited.

State which of these CI fails on and which it only warns about. A contributor who cannot tell the difference treats every rule as optional or every rule as blocking, and both are wrong.

- [ ] **Step 3: Route to it from the index**

`abdm-portal-index` has a "Writing or changing knowledge" branch that names `atom-authoring` for atoms. Add page authoring beside it, and make the distinction explicit: an atom is catalogue knowledge under `catalogue/`, a page is documentation under `site/docs/`. That distinction is the routing decision an agent gets wrong.

This is a compiled skill. Task 2 has already restamped it, so make this edit on top and keep it to the routing entry.

- [ ] **Step 4: Verify the numbers**

For every number in your skill, grep `scripts/lint-content.mjs` and confirm it. Paste each. A page authoring skill whose budgets are wrong is worse than none, because a contributor will trust it over the failure message.

- [ ] **Step 5: Mirror, then commit**

---

### Task 6: Fix the remaining false and misleading claims

Everything in the audit not covered by Tasks 1 to 5. Read `.claude/plugin/DRIFT-AUDIT-2026-08-27.md` as your requirements. It names the skill, the line, the claim, the reality and the evidence for each.

**Files:**
- Modify: the affected skills, agents and commands under `DOCS_REPO/.claude/plugin/`, and their mirrors

**Interfaces:**
- Consumes: the audit
- Produces: a plugin whose remaining claims are true, and an updated audit recording what was fixed

- [ ] **Step 1: Take the work list from the audit**

List every row verdicted `false` or `misleading` that Tasks 1 to 5 did not already cover. Group by file, because fixing one file at a time is fewer mirrors and fewer commits than fixing one row at a time.

Confirm your list against the audit's own count. If your list plus the rows handled by earlier tasks does not equal the audit's total of false plus misleading, you have missed rows. Say so rather than proceeding.

- [ ] **Step 2: Fix the six first-pull-request blockers first**

The audit names them. They are the rows that would cause a contributor's first attempt to be rejected, so they are worth landing even if this task is interrupted:

1. The flat OpenAPI path against the real `<platform>/<version>/` layout
2. The undocumented `verified.status: draft`
3. `plan-sync` sending a contributor to a `plugin/` folder that no longer exists
4. `plan-sync` claiming `plan-check.sh` still checks compiled skill stamps
5. `catalogue-linting`'s rule table, which Task 3 covers
6. `portal-proof` claiming the eval set runs in CI

For each, verify the reality yourself against the file the audit cites before writing the correction. The audit is good, and it is still a document, and this plan exists because documents drift.

- [ ] **Step 3: Fix the rest, file by file**

For each file: make the corrections, mirror it, and check the mirror.

Two you will meet that need judgement rather than a fact swap:

- `skill-compiler` describes a "constrained prose pass" as though a model performs it. `scripts/compile-skills.mjs` says in its own header that a human or the agent running the compile does it by hand afterwards. Describe what happens, and keep the constraint the section exists to state, which is that invented identifiers must not survive.
- `support-agent` describes an agent for one company's support team. Rewrite it as an agent any operator runs against their own Docs MCP endpoint. This is the plugin's only genuinely audience coded text.

- [ ] **Step 4: Update the audit to record what was fixed**

Do not delete rows. Add a `Fixed` column, or a dated section recording which rows this plan closed and which remain. A future reader needs to know the audit was acted on, and which of its rows are still live. An audit silently deleted after being acted on cannot be distinguished from one that was ignored.

Re-verdict nothing. If fixing a row made you doubt its original verdict, record the doubt.

- [ ] **Step 5: Verify the whole plugin**

```bash
cd /private/tmp/claude-502/-Users-samdennis-code-abdm-ai-sandbox-plan/0919c9e0-c6eb-4c2c-aa92-cc6b2d65d962/scratchpad/bible-wt
npm run test:scripts
diff -r .claude/plugin/skills .claude/skills -x README.md && echo "skills ok"
diff -r .claude/plugin/commands .claude/commands && echo "commands ok"
diff -r .claude/plugin/agents .claude/agents && echo "agents ok"
claude plugin validate ./.claude/plugin/.claude-plugin/plugin.json --strict
git grep -l $'—' -- .claude/plugin && echo "FAIL em dash in plugin" || echo "ok no em dash"
node scripts/check-plan-stamp.mjs
```

Everything passes except `check-plan-stamp.mjs`, which reports the four compiled skills against a manifest published on `main` that does not yet carry Task 2's bump. Confirm it names the version Task 2 set.

- [ ] **Step 6: Commit**

---

## What this plan does not do

- `check-bible.mjs`, the check that would stop this drifting again. It is the spec's section 5 and it needs the contract emitter first.
- The four rules folded into the existing linters from the spec's section 4, other than the em dash rule Task 4 covers.
- `AGENTS.md` and the `CLAUDE.md` symlink.
- Making `abdm-docs` public, or resolving that a public marketplace advertises a plugin in a private repository. That is a decision, not an implementation.
- Rewriting `docs-ux` against the real Docusaurus tree beyond correcting its false claims. A full rewrite is its own piece of work.
