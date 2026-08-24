---
description: Read the shared ABDM Developer Portal gantt, propose the status changes that landed work justifies, and apply them once approved.
argument-hint: '[--read|--propose|--rebuild]'
---

Update the shared gantt. Load the `gantt-sync` skill for the rules, the cell map
and the approval gate. Mode: `$ARGUMENTS`. With no arguments, read the Sheet,
propose changes from work landed since the last update, and wait for approval
before writing anything.

## Usage

```
/gantt-update              # read, propose, apply on approval
/gantt-update --read       # current state only, propose nothing
/gantt-update --propose    # propose, do not offer to apply
/gantt-update --rebuild    # plan schedule changed, regenerate the workbook
```

## What it does

1. Reads the live Sheet. Never works from memory of it
2. Gathers what actually landed: `git log`, merged atoms, compiling skills, eval scores
3. Maps each piece onto a WBS number, and names anything that maps to nothing
4. Proposes cell edits as a table, with the evidence for each
5. Stops. Applies only the rows that are explicitly approved

## Output

```
ABDM Developer Portal V1        24 Aug to 5 Sep 2026
12% complete, 1 blocked, 12 days to ship

Proposed:
Row  WBS   Task                    Cell  From          To            Because
10   1.1   Atom schema and lint    H10   0%            100%          schema.json merged, lint live in CI
10   1.1   Atom schema and lint    I10   Not started   Done
11   1.2   Ingest HIE-CM specs     H11   0%            50%           hiecm-v3.yaml in, callbacks AsyncAPI outstanding
11   1.2   Ingest HIE-CM specs     I11   Not started   In progress
23   3.2   Build index and plugin  I23   Not started   Blocked       waiting on 3.1

Landed but on no task:
  scripts/plan-check.sh gate extended. Not in plan#p8-schedule. Add a task or leave it off.

Apply these five edits?
```

## Rules it will not break

Writes to two columns only, `H` and `I`, and never to a stream row. Due dates,
stream rollups, the header counters and the day grid are all formulas. Typing
over one stops the sheet tracking reality.

Moving a date or duration is a plan change, not a status update. It routes to
`plan-sync` and `--rebuild`, not to a cell edit.

Approval is per batch, never standing.

## Rebuild

`--rebuild` is for when plan#p8-schedule has changed and the workbook structure
has to follow. It exports current status first so progress survives, regenerates
from `gantt/build_gantt.py`, and hands back the file with the import step.

The import is File > Import > Replace spreadsheet inside the existing Sheet.
Uploading a new file gives a new URL and orphans every link already shared with a
partner.

Full mechanism: `gantt-sync`.
