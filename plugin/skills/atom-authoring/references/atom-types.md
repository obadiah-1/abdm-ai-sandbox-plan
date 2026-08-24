# Atom types and their specific requirements

Ten types. Each has a shape beyond the five mandatory sections. Read only the one you are writing.

## concept

Explains an idea a developer must hold before any endpoint makes sense. Consent artefact, care context, HIP and HIU roles, Beckn verbs, claim cycle.

- No curl. If it needs a curl it is a flow or an endpoint.
- Section 3 explains the model, not a sequence of calls. A diagram is usually better than prose here.
- Section 4 is unusual for concepts. Use "you know you have understood this when you can answer" and give two questions.
- Always linked from the flows that assume it.

## flow

An end-to-end journey with more than one call. Creating an ABHA by Aadhaar, linking a care context, raising a consent request.

- Section 3 requires a mermaid sequence diagram naming every participant, including NHA's gateway and the patient's PHR app where relevant.
- Every step in the diagram must correspond to an endpoint atom in `related.endpoints`.
- Asynchronous steps must state the wait and what arrives. A flow that hides an await produces a skill that hangs.
- Section 4 is the exit condition for the whole flow. Individual step exits live on the endpoint atoms.

## endpoint

One OpenAPI operation. Usually generated as a stub by ingestion, then given prose by hand.

- Section 3 carries the working curl with every header shown, including `REQUEST-ID`, `TIMESTAMP` and `X-CM-ID` where the gateway needs them.
- Record the actual sandbox response in a fenced `response` block once verified.
- Note idempotency: whether retrying with the same identifier is safe. This is asked constantly and documented rarely.
- Link the callback atom if the operation is asynchronous. A 202 with no callback link is an incomplete atom.

## callback

Something NHA sends to the integrator. Described in the AsyncAPI file, given prose here.

- Section 2 must state what registration made this callback possible.
- Section 3 shows the payload the integrator receives and the acknowledgement expected back.
- State the retry behaviour: how many times NHA retries, over what window, and what a duplicate delivery means for the integrator's idempotency.
- Section 5 should always include "it never arrives", because that is the most common report.

## error

One error code. `ABDM-1035`, `GATEWAY-1401`.

- Title is the code plus the human meaning.
- Section 1 says what actually went wrong in plain words, not a restatement of the code.
- Section 3 is not a sequence. Use it for the conditions that produce this error.
- Section 4 becomes: how you know the fix worked, expressed as the original step's exit condition.
- Section 5 is the fix or fixes. If exactly one fix exists with no judgement, set `fix.deterministic: true`.
- Link every flow and endpoint that can produce it. This is what makes the debug skills work.

## test

One NHA functional test case, one atom.

- Carry NHA's own test case identifier in the title so a certifier can match it.
- Section 2 lists preconditions as checkable state, not narrative.
- Section 3 is the steps as a runnable sequence.
- Section 4 is the pass criterion exactly as NHA words it, with our observable restatement underneath.
- Mark steps needing a human, such as an OTP entry, with a `precondition` block carrying `human: true`. Test skills use this to stop and ask rather than fail.

## decision

A fork the integrator must choose at, where both branches are legitimate. Data custody, integration method, HIP versus HRP.

- Section 3 is a comparison table, not a sequence.
- State the default and say why. A decision atom with no recommendation makes the reader do the work twice.
- Section 4 is how they know they chose correctly, usually a property of their own system.
- Section 5 is what happens when they chose wrong and need to switch, including whether switching is possible after go-live.

## glossary

One term. ABHA, HFR, X-CM-ID.

- Two to four sentences. If it is longer it is a concept.
- Say the expansion, then what it means in practice, then where the reader will meet it.
- No sections 2 and 3 in the usual sense; keep the headings and write "Nothing" under 2 if that is true. Lint requires the headings, not padding.
- Every acronym in the Catalogue links here on first use in every atom, so this is the most linked-to type. Keep the id obvious.

## fhir

One profile or bundle type. OPConsultation, Prescription, DiagnosticReport.

- Section 3 carries a minimal valid bundle, not a maximal one. The reader will add fields; they cannot subtract confidently.
- Name the required resources and the coding systems, including where SNOMED or LOINC is mandatory rather than encouraged.
- Section 4 is the NRCeS validator passing, with the exact command.
- Section 5 is the common validation failures, which are mostly missing `meta.profile` and wrong code systems.

## sandbox

Environment and access mechanics. Registration, credentials, callback URL, test identities.

- These are the atoms the first-day developer reads first, so they carry the heaviest dummy-proof burden.
- State turnaround times honestly, including anything that takes days and is outside our control.
- Never include a real credential, even an expired one.
- Section 5 should cover the state where the reader is waiting on NHA and cannot proceed, because otherwise they assume they did something wrong.
