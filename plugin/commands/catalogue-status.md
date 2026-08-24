---
description: Coverage and verification state of the ABDM Catalogue by gateway, milestone and atom type.
argument-hint: '[--gateway <g>|--milestone <M>|--stale|--gaps]'
---

Report where the ABDM Catalogue actually is. Filters: `$ARGUMENTS`. With no arguments, report everything.

Where the Catalogue actually is, as opposed to where it feels like it is.

## Usage

```
/catalogue-status
/catalogue-status --gateway hiecm
/catalogue-status --milestone M2
/catalogue-status --stale            # everything needing attention
/catalogue-status --gaps             # what is missing rather than what exists
```

## What it reports

**Coverage** per gateway and milestone: atoms by type, against the expected set derived from the ingested OpenAPI operations. An endpoint in the spec with no atom is a gap.

**Verification** counts: verified, unverified, stale, and the age of the oldest verification.

**Scope** compliance: no atom carries `gateway: nhcx`, no atom exists for M4 or UHI, and nothing in M1 to M3 claims dummy-proof depth without all five sections.

**Graph health**: dangling ids, orphan atoms, flows with no skill target, flow steps with no endpoint atom.

**Blockers to the definition of done**, mapped to the numbered list in `portal-planning`, so the gap between here and shippable is explicit rather than estimated.

## Reading it

The number that matters is not atoms written. It is endpoint atoms verified against sandbox on the dummy-proof paths, because that is what the definition of done requires and what the first-day developer test exercises.

A high atom count with low verification is the failure mode this command exists to make visible.
