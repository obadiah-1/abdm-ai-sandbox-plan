---
name: dpg-governance
description: 'The digital public good constraint on the ABDM Developer Portal: FOSS licensing, no dependency on Eka infrastructure or APIs, the overlay repo boundary for vendor-specific content, governance files, and the acceptance test that proves decoupling. Use whenever anything touches licensing, vendor-specific content, hosting dependencies, contribution process, or when someone proposes adding an Eka endpoint, credential format or URL to the core Catalogue. Also use before any public release.'
plan_version: 2026.08.24-4
plan_source: abdm-v1-phase1-architecture-and-plan.md
plan_hash: sha256:cdb2f0b61402cf7f7d4a278a16a65b77d8dc43d0bb3056ee8039124700aee0d6
compiled_from_plan: true
---

# DPG Governance

The framework is a digital public good. Anyone must be able to run it end to end against NHA's sandbox with zero involvement from any single vendor. We build it for everyone and are the first adopter, not the owner of a dependency.

This is a constraint, not an aspiration, and it is the one most likely to erode quietly.

## The acceptance test

Decoupling is proven operationally, not asserted.

> A team with only NHA sandbox credentials, a laptop and a container runtime can clone the repo, build the docs, install the skills, and follow M1 to a successful sandbox call, having never contacted Eka.

This runs in CI. If it breaks, the release is blocked. It is the difference between open source and Eka-shaped software with a licence file.

## What lives where

| Content | Core Catalogue | Overlay repo |
|---|---|---|
| NHA endpoints, callbacks, error codes | Yes | No |
| NHA functional test cases | Yes | No |
| FHIR profiles per record type | Yes | No |
| Gateway concepts and glossary | Yes | No |
| Sandbox registration with NHA | Yes | No |
| A vendor's wrapper endpoints | No | Yes |
| Vendor credential formats | No | Yes |
| Vendor-specific headers | No | Yes |
| Vendor console screenshots or flows | No | Yes |
| A vendor's bridge identifier | No | Yes |

The overlay repo depends on the Catalogue. The Catalogue never depends on the overlay. This direction is the whole architecture of the constraint.

## The lint rule

`prose.no-vendor-url` fails the build on any vendor hostname in the core Catalogue. It is deliberately blunt. When it fires, the content moves to the overlay; the rule does not get an exemption.

## Governance files, required at first public tag

| File | Must say |
|---|---|
| `LICENSE` | A neutral OSI licence. MIT or Apache 2.0. |
| `CONTRIBUTING.md` | How to propose an atom, the review standard, the writing guide, the verification requirement |
| `SECURITY.md` | How to report a vulnerability, and the rule that no credential or patient data ever enters the repo |
| `GOVERNANCE.md` | Who decides, how a decision is recorded, how a new maintainer is added, how another organisation adds content |
| `CODE_OF_CONDUCT.md` | Standard adoption |

`GOVERNANCE.md` is the one people skip and the one that matters for DPG registry listing. It must answer: what happens when Eka and another contributor disagree?

## Contribution path for other organisations

The framework is credible only if someone else can contribute meaningfully. In practice:

- Anyone can open a pull request with an atom
- The verification requirement applies equally: their claim of `verified` needs a recorded response like anyone else's
- Another organisation can add its own overlay without asking permission
- Nobody needs Eka's infrastructure to test their contribution

## Hosting dependencies

Everything is self-hosted from day one: no hosted-Scalar phase, no vendor cloud dependency. Docusaurus with the MIT Scalar packages vendored at build time, nothing loading from a CDN, every Scalar cloud touchpoint off (request proxy, Ask AI, hosted API client link, telemetry, platform toolbar). The exit is already taken, and kept open by the content rules in `scalar-docs`: plain markdown, MDX only for callouts and steps, every page readable as raw `.md`. The handover unit is one compose file: the docs-mcp distroless image plus stock Ollama with the model volume.

The test: could this Catalogue be rendered by a different static site generator in a week, losing only visual polish? If the answer becomes no, the constraint has eroded.

## Review questions before any public release

- [ ] Does the acceptance test pass in CI?
- [ ] Does `prose.no-vendor-url` pass on the core Catalogue?
- [ ] Are all five governance files present and current?
- [ ] Is the licence neutral and applied to every file?
- [ ] Can a page be read as raw markdown with nothing lost but styling?
- [ ] Does any documented workflow require an account with a specific vendor?
- [ ] Does `GOVERNANCE.md` answer the disagreement question?

## When someone proposes vendor content in the core

The answer is not no. The answer is: that belongs in the overlay, here is how to add it there, and here is what the core needs instead if the underlying need is real.

Usually the underlying need is real and generic. "We need to document how to register a webhook" is a core need. "We need to document how to register a webhook in our console" is overlay.

## Related

- Where new things belong: `portal-architecture`
- Content portability rules: `scalar-docs`
- The lint rules: `catalogue-linting`
