---
description: Set up, run and score the first-day developer test for the ABDM Developer Portal.
argument-hint: '[--prepare|--score]'
---

Run the first-day developer test. Load the `portal-proof` skill and follow the procedure below. Mode: `$ARGUMENTS`. If empty, ask whether this is preparation or scoring.

The only instrument that measures dummy-proofness. Everything else measures whether the machine works.

## Usage

```
/firstday-test --prepare     # checklist and materials for the facilitator
/firstday-test --score       # record the result and file the gaps
```

## Setup

A developer with no ABDM exposure. Give them three things: the docs URL, sandbox credentials, a timer. Nothing else. No introduction, no walkthrough, no person to ask.

Task: reach a successful M1 ABHA verification call against sandbox.

Pass: under two hours, no human asked.

## Facilitator rules

- Do not hover. Being watched changes the result.
- Ask them to narrate what they are looking for, and to say when they are confused rather than pushing through.
- Record confusion even when they recover. Recovery consumed time the next person may not have.
- **Do not answer questions.** If they ask, the test has failed on that point. Note it, then decide whether to let them continue for the remaining data.

## Scoring

Pass or fail on the two-hour, no-help criterion. Then, more usefully, the list of every point of confusion with a timestamp, each filed as a Catalogue issue against the atom responsible.

## Expected failure modes

Most failures are atom bugs, not site bugs:

- Section 2 assumed something the reader did not have
- An acronym unlinked, making a sentence unreadable
- A credential step nobody documented because the whole team already had credentials
- Section 4 said 200, so the reader thought they were finished when they were not
- The error they hit was absent from section 5, leaving them nowhere to go

## When to re-run

Before ship, and again whenever the M1 path changes materially. Each run needs a fresh developer, which is the real constraint on frequency. Recruit before you need one.
