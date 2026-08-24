---
description: Run an ABDM endpoint or flow atom against the sandbox and record the observed response, setting verification status honestly.
argument-hint: <atom-id> | --milestone <M> | --stale
---

Verify an ABDM atom against the sandbox and record what you observed. Load the `portal-proof` skill and follow the procedure below. Target: `$ARGUMENTS`. If empty, ask which atom, milestone or selector to verify.

Prove an atom by running it. The only path to `verified.status: verified`.

## Usage

```
/atom-verify <atom-id>
/atom-verify hiecm.endpoint.links-link-add-contexts
/atom-verify --milestone M1          # every unverified atom in M1
/atom-verify --stale                 # everything the watcher flipped
```

## Prerequisites

- Sandbox credentials, and knowledge of which facility they belong to
- A callback receiver for asynchronous atoms. Start one with the `callback-tunnel` tool. Without it, asynchronous atoms report blocked rather than verified.

## What it does

1. Checks section 2 preconditions are actually true. Stops if not.
2. Runs the curl exactly as written in the atom. If it does not run as written, that is a finding about the atom.
3. Captures the full response including headers. Waits for callbacks up to the timeout in section 4.
4. Compares observation to section 4's claim.
5. Sets status, redacts, records.

## Status outcomes

| Observed | Status set |
|---|---|
| Matches section 4 | `verified`, with response recorded, `on` and `by` filled |
| Differs from section 4 | stays `unverified`, discrepancy reported, issue opened |
| Curl failed as written | stays `unverified`, the atom needs fixing first |
| Sandbox unavailable or gateway 403 | stays `unverified`, condition recorded for section 5 |
| Precondition unmet | stays `unverified`, reported blocked |

## Redaction

Automatically replaced with named placeholders: credentials, tokens, Aadhaar numbers, OTPs, full mobile numbers. Kept: ABHA identifiers created for testing, transaction ids, request ids, HFR and HPR ids.

Redaction replaces rather than deletes, so the response shape stays readable.

## Note

This command never edits an atom's claim to match what it observed. A discrepancy is reported for a human to resolve, because either the atom or the expectation was wrong and only a person can say which.
