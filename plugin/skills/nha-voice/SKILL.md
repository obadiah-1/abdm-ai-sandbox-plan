---
name: nha-voice
description: The voice and audience of everything published on the ABDM Developer Portal. The portal is published by NHA and addressed to integrators, so pages state what ABDM does rather than reporting what NHA's documents say. Use when writing or editing any page, atom or compiled skill, when a draft cites NHA in the third person, when prose describes how the documentation was produced, when a page says the sandbox has not been tried, and when reviewing anyone's draft before it ships. Applies to generated prose as well as hand written prose.
---

# NHA Voice

Binding. A page in the wrong voice fails review the same way a broken link
does, and it fails for a worse reason: it tells the reader they are holding a
third party's notes about ABDM rather than ABDM's own documentation.

## Who is speaking, and to whom

**The publisher is NHA.** Not a vendor, not a consultancy, not a team
assembling a catalogue from NHA's PDFs. The portal is ABDM's documentation.

**The reader is an integrator.** A developer at a hospital, laboratory,
pharmacy, insurer or PHR app, with a repository open, who has to make ABDM
work. They came for the contract and the steps, not for an account of how this
page came to exist.

Everything below follows from those two sentences.

## The three defects

Each is drawn from a page currently published. The fix is never to soften the
sentence; it is to change who is speaking.

### 1. Attribution noise

NHA does not cite NHA. Sourcing is real, and it belongs in frontmatter.

| Instead of | Write |
|---|---|
| "NHA's M3 document says a granted request returns the ids of the consent artefacts created against it, plural." | "A granted request returns the id of every consent artefact created against it. Store all of them." |
| "NHA gives its validity as six months and says to validate it before use." | "A link token is valid for six months. Validate it before use." |
| "NHA marks implementing all HI types as mandatory for an HMIS." | "An HMIS must implement every HI type." |
| "NHA states the first. The rest follow from the flows." | Delete the sentence. State the prerequisites. |

Keep a named attribution only where the reader must go to a source that is not
ours: an HL7 value set, the Local Government Directory, the FHIR profiles at
nrces.in. Those are citations, not hedges.

### 2. Production-process leakage

How this documentation was assembled is invisible to the reader. A sentence
about conversion, collections, screenshots or missing specification files is
an internal note that escaped into production.

| Instead of | Write |
|---|---|
| "NHA has published no OpenAPI file for the PHR role. These operations are derived from NHA's Aarogya Setu collection rather than from a specification." | Nothing. Document the operations. |
| "NHA's document carries about 95 screenshots, each a request or response sample. In most cases the screenshot is the only place the method and path appear, so both are missing here." | "Method and path are not yet published for the calls below." |
| "## What did not survive the conversion" | Delete the section. What is documented is documented; what is not does not need a memorial. |
| "The prose is derived from the collection, not written from a specification." | Nothing. |

The reader cannot act on any of it. If a gap is real and load bearing, say
what is missing in platform terms and what to do instead, then stop.

### 3. Self-doubt in the platform's voice

NHA operates the sandbox. A page published by NHA cannot say NHA has not tried
its own endpoint. This is the defect that most often hides a genuine problem,
so it has its own ladder below rather than a substitution table.

## The uncertainty ladder

Uncertainty is not permission to guess, and confidence is not permission to
invent. When a fact is unresolved, walk this ladder and stop at the first rung
that holds.

1. **Resolve it.** Run the call against sandbox, or ask the team that owns the
   endpoint. Most unresolved facts are one request away.
2. **State the operative rule that holds under either reading.** When two
   published tables disagree on a code, the instruction that survives both is
   the one to publish: fetch the codes from the master data call rather than
   hard coding either table.
3. **State availability in platform terms.** "Not available in sandbox."
   "Available from v3.1." "Method and path are not yet published." These are
   statements about ABDM, which NHA is entitled to make.
4. **Omit.** If none of the first three hold, the claim does not ship.

Never publish doubt as prose. "We have not run this", "we cannot tell you
which applies", "treat the response shape as unconfirmed" and "read the
validation error to find out" are all rung zero, and rung zero does not exist.

**Frontmatter is unchanged.** `verification: unverified` stays on the page and
keeps meaning exactly what it meant. It is metadata: it drives the compiler,
tells maintainers what to prove next, and travels with the atom. The reader
does not need it narrated at them, and the presence of honest metadata is what
makes an authoritative sentence safe to write.

## What does not change

This skill governs voice. It does not license overclaiming, and it does not
touch the rest of the writing guide.

- Short sentences. One idea each. Say "you" and "your system".
- No em dash, ever. No "simply", "just", "obviously", "of course", "merely".
- Every acronym links to the glossary on first use, in every page.
- Every code sample runs as written once placeholders are filled.
- Name the observable, not the feeling: "You receive `status: SUCCESS` within
  60 seconds", never "it should work".

**One rule is superseded.** The writing guide says to write "We have not run
this against sandbox yet" in prose. That was right when the catalogue was
assembled from the outside. It is wrong in NHA's voice. The honesty it
protects now lives in frontmatter and in the ladder above.

## Naming ABDM's own parts

In NHA's voice the gateway, the registries and the milestones are ours, not a
third party's. Write "the HIE-CM gateway", "the ABHA registry", "Milestone 2".
Do not write "NHA's gateway" or "the NHA registry": the possessive reintroduces
the outside observer the rest of this skill removes.

Say "we" only where NHA is genuinely acting on the reader's behalf, and rarely:
"We issue the token", not "we think", "we believe", "we have not checked".

## Review checklist

Reject a draft that trips any of these.

- [ ] Does a sentence report what a document says, rather than what ABDM does?
- [ ] Does any prose mention conversion, screenshots, collections, Postman, or
      a missing OpenAPI file?
- [ ] Does any sentence say we have not run, tested, or confirmed something?
- [ ] Does a heading memorialise a gap ("What did not survive", "What the
      sources give you")?
- [ ] Is "NHA" used possessively about ABDM's own components?
- [ ] Would an integrator have to know how this portal was built to understand
      the sentence?

The last question is the one that catches what the others miss.

## Related

- Prose rules this sits on top of: `writing-guide`
- Where a page goes and in what order: `docs-ux`
- Page structure and section headings: `atom-authoring`
- Review process: `atom-review`
