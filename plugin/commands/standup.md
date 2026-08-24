---
description: 'Produce the ABDM Developer Portal standup: what moved, what is blocked, what ships at the next checkpoint.'
argument-hint: '[--checkpoint|--done]'
---

Produce the ABDM Developer Portal standup. Load the `portal-planning` skill for the schedule and the definition of done. Scope: `$ARGUMENTS`. With no arguments, report since the last standup.

## Usage

```
/standup                   # since the last standup
/standup --checkpoint      # against the next two-day increment
/standup --done            # against the definition of done
```

## Shape

Three sections, in this order, kept short.

**Moved.** Atoms written and verified, skills compiling, what an integrator can now do that they could not before. State it as capability, not activity. "M1 endpoint atoms verified against sandbox" rather than "worked on M1".

**Blocked.** Each blocker with its owner and the decision it needs. A blocker with no named decision is not a blocker, it is a worry. Sandbox credentials, NHA-side reviews and unreachable sources belong here even though nobody on the team can fix them, because they change what is plannable.

**Next checkpoint.** The specific thing an integrator can use at the next two-day increment, and whether it is at risk. If at risk, name what depth gets cut, because the checkpoint does not move.

## Numbers worth reporting

- Endpoint atoms verified against sandbox on the dummy-proof paths, which is the number the definition of done actually turns on
- Stale atoms outstanding
- Eval score, if it has been run since the last standup
- Days until the next checkpoint

## Numbers not worth reporting

Total atom count. It rises steadily regardless of whether anything is verified, and it makes a stalled project look busy.

## Against the definition of done

`--done` walks the eleven numbered items in `portal-planning` and reports each as met, partial or not started, with the specific missing piece. Use this in the last week rather than the general form.
