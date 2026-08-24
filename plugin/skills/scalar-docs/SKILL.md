---
name: scalar-docs
description: Building and operating the Scalar documentation site for the ABDM Catalogue, including project setup, navigation generated from atom frontmatter, versions, themes, custom domains, preview deploys, and the two MCP surfaces Scalar provides. Use whenever working on the docs site itself, configuring scalar.config.json, deciding how pages are grouped, setting up or explaining the Docs MCP and Installation MCP, or evaluating the self-host path.
---

# Scalar Docs

Scalar renders the human half of the Catalogue and gives us two MCP surfaces without building them. It does not author guides, compile skills, watch sources or enforce our lint rules. Knowing that boundary prevents a lot of wasted effort.

## What we get without building it

- Interactive OpenAPI references for all three gateways
- AsyncAPI rendering for callbacks
- Search and an Ask AI surface over published content
- A Docs MCP at `your-docs-domain/mcp`
- An Installation MCP generated from the OpenAPI files
- Preview deployments per pull request, GitHub sync, publish from CLI
- Spectral linting in CI
- A mock server from the OpenAPI, which lets a developer hit fake endpoints before sandbox credentials arrive

That last one matters more than it looks. Sandbox credentials take days. The mock server means the first-day developer test is not blocked on NHA.

## What we build ourselves

- The atom bodies. Scalar renders markdown; it does not write guides.
- Navigation generation from frontmatter, because hand-maintained navigation drifts.
- The skill compiler.
- The source watcher.
- Our lint rules beyond Spectral.

## Navigation is generated, never hand-edited

`scalar.config.json` navigation is a build output. The generator walks atom frontmatter and groups gateway, then milestone, then type, mirroring the flow-page structure integrators already find readable.

Hand-editing navigation is the same class of mistake as hand-editing a compiled skill. If a page is in the wrong place, its frontmatter is wrong.

The generator also emits:

- Depth labels on UHI and NHCX sections, visible in the sidebar, not only on the page
- Verification banners for `unverified` and `stale` atoms
- The `catalogue_version` in the footer, so a reader can tell an agent which version they are looking at

## Versions

Scalar Versions map to NHA spec versions, not to our release cadence. `abdm-v3` is a version. A Catalogue rebuild is not.

When NHA publishes a new spec version, it becomes a new Scalar version with its own atom set. Atoms are not edited in place across spec versions, because integrators mid-certification need the version they started on.

## The two MCP surfaces

These are easy to conflate and behave very differently.

| | Docs MCP | Installation MCP |
|---|---|---|
| Lives at | `your-docs-domain/mcp` | a separate Scalar-hosted installation URL |
| Does | Search and read published documentation | Exposes API operations as tools |
| Visibility | Inherits the docs project visibility. Public docs means public MCP. | Private by default, returns 401 without credentials |
| Auth | None for public docs, rate limited at the load balancer | Personal access token, or passthrough per installation |
| Modes | Read only | Search or Execute, per operation |
| V1 use | Powers the internal support agent, and any external agent wanting the docs | Agents generating correct requests. Search mode only by default. |

**Execute mode stays off by default.** An MCP that can call NHA's sandbox with a shared credential is a footgun: one caller exhausts a rate limit, creates identities, or pollutes state for everyone. When execute is enabled for trusted testers, it uses passthrough so each caller brings their own sandbox credentials and nothing is stored centrally.

Billing note worth knowing before enabling anything broadly: Docs MCP queries are metered like Ask AI messages.

## Content constraints that protect portability

Principle P6 says no lock-in. In practice:

- Keep prose in plain markdown. Use MDX only for callouts and steps.
- No Scalar-specific component carrying meaning that would be lost in plain markdown.
- Every page must still read correctly as a raw `.md` file, because that is what agents fetch.

This keeps the self-host path open and keeps `llms.txt` and per-page markdown honest.

## Publishing

- Preview deployment on every pull request. Reviewers read the rendered page, not the diff, because dummy-proofness is judged in rendered form.
- Publish on merge to main, after lint and compile pass.
- The docs and the compiled skills publish from the same build, so their `catalogue_version` always matches.

## Self-host path

Scalar's core is MIT licensed. We use hosted for V1 speed and document the self-host path as the exit. The evaluation is a Phase 2 item, but the constraint that makes it possible is enforced now, in the content rules above.

## Related

- What renders: `atom-authoring`
- Who consumes the Docs MCP: `support-agent`
- Publishing mechanics: `/docs-publish`, `update-pipeline`
- Why lock-in matters: `dpg-governance`
