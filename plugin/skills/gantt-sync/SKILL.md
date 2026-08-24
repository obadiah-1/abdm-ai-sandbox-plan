---
name: gantt-sync
description: Keep the shared ABDM Developer Portal gantt in Google Sheets honest as work lands. Covers where the gantt lives, what is a formula and must never be typed over, how to decide a task is genuinely done rather than merely worked on, the approval gate before any write, and how to rebuild the workbook from the plan without losing live progress. Use whenever a task finishes or slips, when someone asks where the project stands, when the plan schedule changes, or before sharing the gantt with a partner.
---

# Gantt Sync

The gantt is the only artefact partners see. It is shared outside the team, so a
wrong bar is worse than a missing one.

## Where it lives

| Thing | Where | Who owns it |
|---|---|---|
| The shared gantt | [Google Sheet](https://docs.google.com/spreadsheets/d/17OkDm9-wUSgMZ5G2Tegv69-MP-aXTdjjjN37t4-HxSE/edit) | The ledger. Live status lives here and nowhere else. |
| Task structure | `gantt/build_gantt.py`, the `TASKS` table | Compiled from plan#p8-schedule. Not a second source. |
| Rebuild instructions | `gantt/README.md` | |

Four tabs: `Gantt`, `Checkpoints`, `Definition of done`, `Actions`.

## The one rule

**Status lives in the Sheet. Structure lives in the plan.**

Task names, dates, durations, owners and streams come from plan#p8-schedule
through `gantt/build_gantt.py`. Percent complete and status come from work
actually landing, and are typed into the Sheet.

Two mutable copies of progress means drift, and drift in the artefact partners
read is the failure this rule exists to prevent. So there is no `status.json` in
the repo, and there never should be. A rebuild reads current status back out of
the Sheet before it overwrites anything.

## What is a formula and must never be typed over

| Cells | What they are |
|---|---|
| `G9:G34` Due | `=IF(Days=0, Start, Start+Days-1)`. Change Days, not Due. |
| Rows 9, 16, 21, 26, 30 | Stream rollups. Start, Days, Due and % Done are all MIN, MAX and weighted averages of their children. |
| `F5:H6` header counters | Percent complete, days to ship, task count, blocked count. |
| The day grid `J9:Y34` | Empty cells. Every bar is conditional formatting reading Start, Days, Due and % Done. There is nothing to type there. |

Typing a value over any of these replaces a formula with a constant, silently,
and the sheet stops tracking reality from that cell onward.

**This skill writes to two columns only: `H` (% Done) and `I` (Status), on task
rows.** Never a stream row. Never anything else.

Task rows are those whose WBS has a dot, plus row 34 (Ship V1). Data starts at
row 9, in the order of the `TASKS` table in `gantt/build_gantt.py`.

## The loop

**Observe.** Read the live Sheet before proposing anything. Never work from
memory of what it said last session, and never from what the plan says should
have happened.

```
read_file_content(fileId="17OkDm9-wUSgMZ5G2Tegv69-MP-aXTdjjjN37t4-HxSE")
```

Then observe what actually landed: `git log` since the last update, atoms merged,
skills compiling, `/catalogue-status`, `/eval-run` scores.

**Orient.** Map each piece of landed work onto a WBS number. Work that maps to no
task is the interesting signal, not a rounding error. Either the plan is missing
a task or the work was not on the plan. Say which.

**Decide.** Propose changes as a table, one row per cell edit, with the evidence
that justifies it. Nothing is applied at this stage.

```
Row  WBS   Task                    Cell  From          To            Because
10   1.1   Atom schema and lint    H10   0%            100%          schema.json merged, lint rule live in CI
10   1.1   Atom schema and lint    I10   Not started   Done
11   1.2   Ingest HIE-CM specs     H11   0%            50%           hiecm-v3.yaml in, callbacks as webhooks outstanding
11   1.2   Ingest HIE-CM specs     I11   Not started   In progress
23   3.2   Build index and plugin  I23   Not started   Blocked       waiting on 3.1, compiler not passing validation
```

**Act.** Only after an explicit yes. See the approval gate below.

## When a task is genuinely done

A task is done when the capability it was for is true, not when the work felt
finished. The test is external.

| Stream | Done means |
|---|---|
| Catalogue | Atoms merged, lint passing, and for M1 to M3 endpoint atoms, a curl run against sandbox with the response recorded |
| Site and MCP | The page or surface is reachable and behaves, not that the config is written |
| Skills | The skill compiles, validates and installs, not that the template exists |
| Pipeline | It has run once for real, not that it is deployed |
| Proof | The score is recorded, not that the harness runs |

Where the task feeds a checkpoint in plan#p8-2-increments or a criterion in
plan#p9-done, that wording is the exit condition. Use it verbatim rather than
inventing a looser one.

Partial credit is honest and useful. A two-day ingest task with the OpenAPI in
and the callbacks not yet described is 50%, not 100% because the hard part is
over.

## The approval gate

**Never write to the Sheet without an explicit yes on the specific edits.**

Approval is per batch, not standing. A yes to marking 1.1 done is not a yes to
marking 1.2 done next time. Re-propose every batch.

Ask once, with the table above, and accept a partial yes. If the answer is yes to
some rows and no to others, apply only the approved rows and say which you
skipped.

Three things always stop and ask rather than being proposed as routine:

- Moving a date or a duration. That is a plan change, not a status update.
- Marking anything on the `Definition of done` tab. Those are ship criteria.
- Anything that would make the Ship V1 milestone look reachable when the
  checkpoint behind it is not.

## Applying an approved batch

Google Sheets cannot be written through the Drive tools, which only read and
create. Two paths, in order of preference.

**Hand over the edits.** Give the cell references and values as a short list. It
is a few keystrokes for whoever approved them, and it works with no browser
connected.

```
H10 = 100%   I10 = Done
H11 = 50%    I11 = In progress
             I23 = Blocked
```

**Drive the Sheet in a browser.** If a Chrome with the user's Google session is
connected, open the Sheet, click each cell, type the value. Read the cell back
after typing. Do not batch-paste a range: one mis-aligned paste overwrites a
formula column and the sheet stops tracking.

Either way, confirm afterwards by reading the Sheet again and reporting the new
header counters: percent complete, blocked count, days to ship.

## When the plan schedule changes

A date, duration, owner or task change is a plan change first. The order matters
and the gate enforces it.

1. Edit `abdm-v1-phase1-architecture-and-plan.md` and follow the full procedure in `plan-sync`
2. Edit the `TASKS` table in `gantt/build_gantt.py` to match
3. Restamp `PLAN_VERSION` in `gantt/build_gantt.py` to the new `plan_version`
4. Export the live Gantt tab as CSV, so current progress is not lost
5. Rebuild with the status carried forward
6. Import the result into the existing Sheet

```sh
python3 gantt/build_gantt.py --status live.csv
```

**Step 6 is File > Import > Replace spreadsheet, inside the existing Sheet.**
Uploading the workbook as a new file creates a new URL, which orphans every link
already shared with a partner. There is no way to undo that for someone who has
already bookmarked the old one.

`scripts/plan-check.sh` fails when the plan hash moves and the gantt generator's
`PLAN_VERSION` does not, so step 3 cannot be quietly skipped.

Adding or removing a task shifts every row number below it. Re-read the Sheet
after a rebuild before proposing any cell edit against the old numbering.

## Sharing with a partner

Share view-only unless the partner is expected to update their own rows. The
status dropdowns and conditional formatting work fine for a viewer.

Before sharing, check three things:

- No task is showing green past a checkpoint that has not actually been met
- The `Actions` tab has no stale decision sitting at "Not started" past its due date
- Nothing implies coverage the plan does not claim. Phase 1 is HIE-CM M1 to M3
  only; M4 and UHI are Phase 2 and NHCX is out of scope, per plan#p7-coverage

## What this does not solve

The gantt reports what someone typed. It cannot tell that a task marked done was
marked optimistically. The approval gate is the only defence and it is human,
exactly as with the plan itself.

## Related

- The schedule this is compiled from: `portal-planning`, plan#p8-schedule
- Editing the plan that feeds it: `plan-sync`
- What moved and what is blocked, in prose: `/standup`
- Coverage and verification state behind a percentage: `/catalogue-status`
- Apply it: `/gantt-update`
