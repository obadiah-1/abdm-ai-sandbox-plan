---
description: Run the six ABDM Developer Portal eval tasks against the sandbox and record the score.
argument-hint: '[<n>] [--record] [--since <version>]'
---

Run the ABDM Developer Portal eval tasks and score them. Load the `portal-proof` skill. Selection: `$ARGUMENTS`. With no arguments, run all six.

Measures whether an agent can do the work using only the plugin and the MCP.

## Usage

```
/eval-run                    # all six
/eval-run <n>                # one task
/eval-run --record           # write the score to the eval log
/eval-run --since <version>  # re-run only what a Catalogue change could have affected
```

## The tasks

1. Scaffold an ABHA verification flow from an empty repo
2. Build and validate an OPConsultation bundle
3. Link a care context and push encrypted data
4. Raise an HIU consent request and fetch records
5. Diagnose a failing HIP data push from its error
6. Walk the M1 to M3 test cases to completion

## Scoring

Pass or fail against the exit condition from the relevant atom. No partial credit, because partial credit hides the ambiguity the exit conditions exist to remove.

Also recorded per task: which atoms the agent cited, and how many loops it took. An agent that succeeded citing nothing is a warning, not a pass to celebrate: it used ambient knowledge and will be wrong wherever the Catalogue contradicts its training.

## Prerequisites

Sandbox credentials, a callback receiver, and a clean repository for the scaffolding tasks. Check the sandbox is up before concluding anything from a failure.

## When a task fails

Diagnose in this order: is section 4 observable, is section 5 real, is the error atom linked, is the template wrong, is the sandbox down. Most failures are the first two.

Every failure produces a Catalogue issue with the atom id.
