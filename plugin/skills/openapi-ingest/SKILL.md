---
name: openapi-ingest
description: How to bring NHA's specifications into the ABDM Catalogue: fetching swagger from the sandbox, pulling UHI and NHCX specs from GitHub, hashing and recording sources, cleaning inconsistent files without hiding the change, describing callbacks as AsyncAPI, and generating endpoint atom stubs. Use whenever adding a new NHA source, refreshing an existing one, generating endpoint stubs, handling a spec that is broken or incomplete, or deciding how to record a correction to an NHA file.
---

# OpenAPI Ingest

NHA's specifications are the root of the Catalogue. They are also incomplete, occasionally inconsistent, and in one case served by a JavaScript application rather than as a file. Ingestion handles all three without ever hiding what we changed.

## The sources

| Source | What it gives | How to fetch |
|---|---|---|
| Sandbox swagger YAMLs | HIE-CM V3 operations | Direct fetch, hash, store |
| NHA GitHub organisation | UHI protocol specs and schemas, NHCX, the reference wrapper | Clone or raw fetch per file, hash |
| Sandbox documentation pages | Flow narrative, test cases, known behaviours | Headless fetch, because the site is a JavaScript application |
| Circulars and release notes | Changes that never reach a spec file | Manual drop folder, hashed like any other source |

Every source, including the manual drop, gets a URL, a fetch date and a hash. An atom with an unhashed source fails lint.

## The ingestion sequence

1. **Fetch** the raw file exactly as served. Store the original untouched under `openapi/.raw/`.
2. **Hash** it. `sha256` over the raw bytes. This hash is what the watcher compares against.
3. **Lint** with Spectral. Record the violations; do not fix them yet.
4. **Correct** only what blocks rendering or stub generation. Every correction is recorded, see below.
5. **Split callbacks** out into the AsyncAPI file so Scalar renders them as callbacks rather than as odd request bodies.
6. **Generate stubs**, one endpoint atom per operation, with frontmatter filled and the five section headings empty.
7. **Report** what was generated, what was corrected, and what still fails lint.

## Recording a correction, not hiding it

When an NHA file is wrong, we fix our copy and we say so. The atom's `sources` carries both entries:

```yaml
sources:
  - url: https://sandbox.abdm.gov.in/swagger/ndhm-hip.yaml
    fetched: 2026-08-24
    hash: sha256:abc...
    role: upstream
  - url: openapi/corrections/hiecm-v3.patch
    fetched: 2026-08-24
    hash: sha256:def...
    role: correction
    reason: >
      Upstream omits operationId on three operations, which stub generation
      requires. Added ids matching the path. No schema change.
```

Rules for corrections:

- A correction may add what is missing and fix what is malformed. It may never change a schema to what we think it should be.
- If the correct behaviour is unknown, do not guess. Generate the stub, mark the atom `unverified`, and let sandbox verification settle it.
- Every corrected operation produces an atom that stays `unverified` until someone runs it.

## Known conditions to expect

These are recurring and should surprise nobody:

- Some V3 sandbox endpoints return 403 because of gateway subscription state rather than anything the integrator did. The atom must say this in section 5, or every reader will assume their credentials are wrong.
- Operation ids are inconsistently present.
- The same concept appears under different names across HIE-CM, UHI and NHCX. Do not unify them in the specs. Unify them in the glossary and link.
- UHI follows Beckn verbs, so the request and callback pairing is structural rather than incidental. Generate both sides.
- Sandbox and production base URLs differ in more than the hostname. Record both explicitly per operation.

## Stub generation

One endpoint atom per operation. The generator fills:

- `id` from gateway and operation id
- `type: endpoint`, `gateway`, `version`
- `title` from summary, rewritten later by a human because generated titles read like machine output
- `sources` with the hash
- `verified.status: unverified` always. Generation is not verification.
- `related.callbacks` where the operation is asynchronous and a callback is identifiable

The generator leaves all five sections empty with headings present. It never writes prose. A stub with generated prose is worse than an empty one, because a reviewer might believe it.

## Callbacks as AsyncAPI

Callbacks are the part integrators get wrong most and the part specs describe worst. Model them properly:

- One AsyncAPI channel per callback path
- The payload schema, the acknowledgement expected back, and the retry behaviour
- Link each channel to the operation that triggers it

If NHA's own documentation does not state the retry behaviour, mark it unknown rather than assuming. Retry behaviour drives idempotency design, so a wrong guess here is expensive downstream.

## After ingestion

Ingestion produces stubs, not documentation. The handoff is explicit:

1. Report the stub count per gateway and milestone
2. Flag operations that could not be stubbed and why
3. Dispatch `atom-author` for the bodies, or queue them
4. Dispatch `atom-verifier` once credentials exist

## Related

- What the stubs become: `atom-authoring`
- Watching for changes: `update-pipeline`
- Fixing spec lint failures: `catalogue-lint`
- Manual refresh: `/source-check`
