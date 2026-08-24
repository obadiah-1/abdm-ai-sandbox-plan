---
name: atom-review
description: How to review an ABDM Catalogue atom before merge, including the dummy-proofness test, verification honesty checks, graph integrity, and the specific failure modes reviewers miss. Use whenever reviewing a pull request against the Catalogue, checking someone else's atom, approving a draft, or deciding whether an atom is ready to be marked verified. Also use when an atom passed lint but still feels wrong, because lint checks structure and this skill checks truth.
---

# Atom Review

Lint checks that the shape is right. Review checks that the content is true and usable. Both must pass. An atom that lints clean and lies is worse than one that fails lint, because it ships.

## The reviewer's stance

You are not checking whether the author worked hard. You are standing in for a developer who has never heard of ABDM, has a deadline, and will believe every word. Read as that person. Where you have to bring your own knowledge to make a sentence make sense, the atom has a gap.

## Review order

Work in this order. Stop and request changes as soon as you hit a blocker; do not review the rest out of politeness.

### 1. Verification honesty (blocker)

The highest-severity failure in this repo.

- Does `verified.status` match reality? If it says `verified`, is there a recorded response in the body from an actual run?
- Does `verified.on` correspond to a real date and `verified.by` to a real person?
- If the atom was generated or drafted by an agent and never run, it must say `unverified`.
- If the source hash has changed since verification, status should be `stale`, not `verified`.

Fabricated verification fails review immediately, regardless of how good the rest is.

### 2. The first-day developer test (blocker)

Read section 1 as someone with zero context.

- Is there an acronym without a glossary link?
- Does understanding it require a concept the atom never links to?
- Would this person know whether this atom is the one they need?

Then read section 2. Could that person check every precondition, or are some of them "have the right setup"?

### 3. Section 4 is an observation (blocker)

This is the section reviewers skim and should not.

- Does it name a concrete, observable thing? A status, a payload field, a callback path, a state change.
- Does it state a timeout for anything asynchronous?
- Would an agent know unambiguously whether it had happened?

"Returns 200" is almost always wrong for the async gateway APIs, because 200 means accepted, not done. Push back every time.

### 4. Section 5 is real (blocker)

- Are the failures the ones that actually happen, or the ones that are easy to write?
- Does each link to an error atom that exists?
- Is the most common failure first?

If the author has never seen this flow fail, section 5 is speculation and the atom should say so.

### 5. Graph integrity

- Does every `related` id resolve?
- Are the links reciprocal where they should be? A flow linking an error atom should usually appear in that error atom's own links.
- Does `skills` name skills that exist in the compiler's template set?
- For a flow: does every step in the sequence diagram have a corresponding endpoint atom?

### 6. Prose

Run the `writing-guide` checklist. Most commonly caught: banned words, unnamed placeholders, acronyms unlinked because the author knew what they meant.

### 7. Scope

- Is this one atom or two? Two flows, two types, or two milestones in one file means split.
- Is anything here Eka-specific? It does not belong in the core Catalogue. See `dpg-governance`.
- Is the scope right? Everything in V1 is HIE-CM M1 to M3. An atom for M4, UHI or NHCX does not belong in this Catalogue yet, however good it is.

## Failure modes reviewers miss

| Miss | How to catch it |
|---|---|
| Plausible-sounding response body that was never observed | Ask where the response came from. If the answer is "the spec", it is unverified. |
| Section 2 that lists what the author had, not what is required | Ask what happens if each item is absent. |
| A curl that works only because of shell state | Read it as a fresh terminal. |
| Error atom linked but describing a different condition | Open the error atom. Do not trust the id. |
| Retry and idempotency unstated on an async endpoint | Ask what a duplicate delivery does. |
| Depth label inherited from a sibling file | Check against what was actually run. |
| An atom that duplicates an existing one under a new id | Search the Catalogue for the endpoint path before approving. |

## Review outcomes

- **Approve.** Everything above passes. Say what you checked, so the author knows the review was real.
- **Approve with follow-up issue.** The atom is correct and useful but incomplete in a way that does not mislead. File the issue and link it in the atom.
- **Request changes.** Any blocker. Name the section and the specific sentence. "Section 4 is not observable: what exactly arrives, and within how long?"
- **Request verification.** The content looks right but was never run. Dispatch `atom-verifier` or ask the author to run it, and hold approval.

## What a good review comment looks like

Not: "This section needs work."

This: "Section 4 says the call returns 200. For this endpoint 200 means the gateway accepted the request. The reader needs to know that the actual result arrives at `/on-add-contexts` and what it contains. Also state the wait, because right now an agent using this atom has no exit condition and will loop."

## Related

- What the atom should contain: `atom-authoring`
- Prose rules: `writing-guide`
- Mechanised checks that run before you review: `catalogue-linting`
- Verifying against sandbox: `/atom-verify`
