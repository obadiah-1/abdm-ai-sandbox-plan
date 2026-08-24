---
name: ooda-skill-authoring
description: How to author compiled ABDM skills as OODA loops rather than recipes, covering the four phases, exit conditions drawn from atoms, explicit loop limits, escalation format, deterministic fixes that skip the decide phase, and when parallel loops are allowed. Use whenever writing or fixing a skill template, when a compiled skill loops forever or stops too early, when an agent using a skill escalates badly, or when deciding how a build, test or debug skill should behave against an asynchronous flaky gateway.
---

# OODA Skill Authoring

## Why loops and not recipes

Integration against NHA is asynchronous, the sandbox is unreliable, and the counterparty you need is often absent. A skill written as a recipe fails the first time the sandbox returns something the recipe did not anticipate, and then the agent either invents a next step or stops with nothing useful to say.

So every build, test and debug skill is a loop. Observe, orient, decide, act, back to observe. Speed through the loop matters more than perfection in any single pass.

## The four phases

### Observe

Reads nothing from the Catalogue. Only live facts: the last response, the last callback, the state table, logs, sandbox status, the error code in front of it.

**The skill is forbidden from assuming the previous step worked.** This is the single most important rule. An agent that assumes success and proceeds produces failures three steps later that are almost impossible to diagnose.

Writes an observation record: timestamp, request id, what came back verbatim.

Time box: the wait stated in the relevant atom's section 4. Sixty seconds for a callback, for example. Not indefinite.

### Orient

Reads the atom graph. Matches the observation to a flow step, an error atom, or a test case.

**When the match is not exact, list at least two hypotheses.** A skill that commits to one interpretation of an ambiguous error will confidently apply the wrong fix. Two hypotheses force the decide phase to pick the action that distinguishes them.

Writes a short orientation note naming the matched atom and the alternative.

Time box: one pass. Do not re-read the whole Catalogue.

### Decide

Reads the matched atom's sections 2 and 5.

Picks the cheapest action that produces a new observation. States the hypothesis, the observation that would confirm it, and a fallback. Reversible actions before irreversible ones.

Seventy percent confidence now beats certainty after the sandbox session expires.

### Act

Runs the atom's curl, script or fix. Appends the action and its raw result to the loop log. Returns immediately to observe.

## Exit conditions come from the atom

A skill is done when the matched atom's section 4 is observed. It is never done because the agent feels finished, and it is never done because the loop limit was reached.

This is why section 4 must be observable. A skill whose exit condition is "it works" cannot terminate correctly. When you find a skill that loops forever, the bug is almost always an unobservable section 4 in the atom, not the template.

## Loop limits are explicit

| Skill kind | Limit |
|---|---|
| build | eight loops per flow step |
| test | three loops per test case |
| debug | five loops per error |

Hitting the limit is an escalation, not a failure and not a silent stop.

## Escalation format

An escalation must name three things and ask exactly one question:

1. **What was observed.** The actual responses and callbacks, verbatim, with request ids.
2. **What was tried.** Each hypothesis, the action taken, and why it was ruled out.
3. **Which one atom the human should read.**

Then one question. Not a list of questions. The human is being interrupted; make the interruption cheap.

Bad escalation: "I could not complete the linking step. There may be an issue with the configuration."

Good escalation: "Three link attempts returned ABDM-1035. Facility onboarding is the documented cause and I confirmed `X-HIP-ID` matches your console value, so the alternative hypothesis of a wrong header is ruled out. Read `hiecm.error.abdm-1035`. Has this facility completed HFR onboarding, or is it still pending NHA review?"

## Deterministic fixes skip decide

Some error atoms have exactly one fix and no judgement: a reused REQUEST-ID, a missing X-CM-ID, clock skew outside the accepted window. These carry `fix.deterministic: true` and the compiler emits them as direct actions. The skill goes observe, orient, act.

Use this sparingly. A fix is deterministic only when there is genuinely one cause and one remedy. If the fix depends on how the integrator's system is configured, it is not deterministic.

## Where each skill kind starts and stops

| Kind | Starts by observing | Exit condition | Typical loop count |
|---|---|---|---|
| build | The repo: what exists, which credentials are configured, which steps are already done | Every flow step's section 4 observed once against sandbox | One per flow step |
| test | The test atom's preconditions | Every test case in the milestone passed, or marked needs-human with the reason | One per test case |
| debug | The error, the last request id, the state table | The error atom's fix applied and the original step's exit condition observed | One per hypothesis |

Note that debug does not exit when the fix is applied. It exits when the original thing that failed succeeds. Applying a fix and declaring victory is the most common way a debug skill lies.

## Parallel loops

Allowed only where the index skill declares steps independent. In practice that is FHIR bundle construction per record type, and test cases with no shared state.

Everything else runs one loop at a time, because the state it depends on is shared: the access token, the facility id, the patient id, the consent id. Two loops racing on a shared transaction identifier produce failures that look like gateway bugs.

## Human-required steps

Some steps cannot be automated: entering an OTP, approving a consent in a patient app, waiting for NHA to review a facility. These are marked in the atom with a precondition block carrying `human: true`.

A test skill hitting one of these must stop and ask, then record the case as needs-human with the reason. It must never mark it passed, and it must never mark it failed.

## Authoring checklist

- [ ] Every loop declares a limit
- [ ] Every exit condition traces to an atom's section 4
- [ ] Observe reads live state only, never assumes the previous step
- [ ] Orient produces two hypotheses when the match is inexact
- [ ] Escalation names observation, hypotheses tried, one atom, one question
- [ ] Deterministic fixes are genuinely judgement-free
- [ ] Parallelism only where the index says independent
- [ ] Human-required steps stop and ask

## Related

- How templates become skills: `skill-compiler`
- Where exit conditions come from: `atom-authoring`
- The support agent runs the same loop: `support-agent`
