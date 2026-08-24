---
name: portal-proof
description: 'How the ABDM Developer Portal proves it works: the six eval tasks scored against atom exit conditions, the first-day developer test, how failures become Catalogue issues, and re-scoring on every change. Use whenever running or designing an evaluation, preparing the first-day developer test, scoring a run, deciding whether V1 is shippable, or turning a test failure into work. Also use when someone claims something works without evidence.'
---

# Portal Proof

Two instruments. The eval set measures whether an agent can do the work. The first-day developer test measures whether a human can. Both must pass before ship, and both produce Catalogue issues rather than opinions.

## The six eval tasks

Run by an agent using only the plugin and the MCP. Scored pass or fail against the exit condition from the relevant atom, never against a judgement of effort. Re-run on every Catalogue change.

| # | Task | Exit condition observed |
|---|---|---|
| 1 | Scaffold an ABHA verification flow from an empty repo | Sandbox returns a verified ABHA profile |
| 2 | Build and validate an OPConsultation bundle | The NRCeS validator passes |
| 3 | Link a care context and push encrypted data | `on-add-contexts` callback with SUCCESS, then a data push acknowledged |
| 4 | Raise an HIU consent request and fetch records | Consent artefact received, bundle decrypted and valid |
| 5 | Diagnose a failing HIP data push from its error | Correct error atom cited, fix applied, and the original push then succeeds |
| 6 | Walk the M1 to M3 test cases to completion | Every test atom passed or marked needs-human with a reason |

Two things to note about task 5. The exit condition is the original push succeeding, not the fix being applied. And citing the correct atom is part of the score, because an agent that fixes the right thing for the wrong reason will fail the next variant.

## Scoring rules

- Pass or fail only. No partial credit. Partial credit hides exactly the ambiguity we are trying to eliminate.
- The exit condition comes from the atom, not from the scorer's judgement.
- A task that needs a human step is not a failure. It is recorded as needs-human, and the reason is checked against the atom's `human: true` marker. An unmarked human step is an atom bug.
- Record which atoms the agent cited. An agent that reached the right outcome citing nothing is a warning sign: it used ambient knowledge, and it will be wrong on something the Catalogue contradicts.

## When an eval fails

Diagnose in this order, because the cheapest fix is usually the right one:

1. **Is the atom's section 4 observable?** Most loop failures are unobservable exit conditions.
2. **Is the atom's section 5 real?** Most wrong fixes come from speculative failure lists.
3. **Is the error atom linked?** Debug skills walk links. An unlinked error atom is invisible.
4. **Is the skill template wrong?** Only after the above three.
5. **Is the sandbox down?** Check before concluding anything. Record it if so and re-run.

Every failure produces a Catalogue issue with the atom id, not a note in a spreadsheet.

## The first-day developer test

The instrument that measures dummy-proofness. Nothing else does.

**Setup:** a developer with no ABDM exposure. Give them the docs URL, sandbox credentials, and a timer. Nothing else. No introduction, no context, no person to ask.

**Task:** reach a successful M1 ABHA verification call against sandbox.

**Pass:** under two hours, with no human asked.

**Fail:** anything else, and the point at which they got stuck is filed as a Catalogue issue and fixed before ship.

### Running it properly

- Do not hover. Watching produces a different result than the real thing.
- Ask them to narrate what they are looking for, recorded, and to say when they are confused rather than pushing through.
- Every moment of confusion is data even if they recover. Recovery took time the next person may not have.
- Do not answer questions. If they ask, the test has already failed on that point. Note it, then decide whether to let them continue for the rest of the data.

### What the failures usually are

In rough order of frequency:

- Section 2 assumed something the reader did not have
- An acronym unlinked, so a sentence was unreadable
- The sandbox credential process had a step nobody documented because everyone on the team already had credentials
- Section 4 said 200 and the reader thought they were done when they were not
- The error they hit was not in section 5, so they had nowhere to go

Notice how many of those are atom bugs, not site bugs. That is the point of the test.

## Re-running

- The eval set runs on every Catalogue change, in CI.
- The first-day test runs before ship, and again whenever the M1 path changes materially. It needs a fresh developer each time, which is the constraint on how often it can run.

## What proof does not mean

Passing both instruments means the documentation works for the paths tested. It does not mean the Catalogue is complete, that anything beyond M1 to M3 exists, or that certification will succeed. Say so plainly when reporting results. Overclaiming here undermines the honesty the depth labels are built on.

## Related

- The definition of done these feed: `portal-planning`
- Turning failures into atoms: `atom-authoring`
- Loop behaviour under test: `ooda-skill-authoring`
- Run them: `/eval-run`, `/firstday-test`
