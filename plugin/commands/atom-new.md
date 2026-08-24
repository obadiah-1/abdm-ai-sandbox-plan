---
description: Scaffold a new ABDM Catalogue atom with valid frontmatter and the five mandatory section headings.
argument-hint: <type> <gateway> <slug>
---

Scaffold a new ABDM Catalogue atom. Load the `atom-authoring` skill and follow the procedure below. Arguments: `$ARGUMENTS`, read as type, gateway and slug. If any of the three is missing, ask for it before writing anything.

Create a new atom, correctly shaped, ready to write.

## Usage

```
/atom-new <type> <gateway> <slug>
/atom-new flow hiecm m2-link-care-context
/atom-new error hiecm abdm-1035
/atom-new concept hiecm consent-artefact
```

## What it does

1. Loads `atom-authoring` and the type-specific rules from `references/atom-types.md`
2. Asks the four questions that must be answered before writing: type, source, what the reader already has, how they will know it worked
3. Writes the file to the correct path from gateway and type
4. Fills frontmatter: `id`, `type`, `gateway`, `version`, `verified.status: unverified`
5. Emits the five section headings in order, with type-specific scaffolding inside them
6. Leaves `title`, `summary`, `milestone`, `sources` and `related` for the author

## What it will not do

- Set `verified` to anything but `unverified`
- Write prose into the sections
- Invent a source
- Create an atom whose id already exists

## After running

1. Fill `sources` with a URL and hash. Use `/source-check` if you need the hash.
2. Write the five sections. Follow `writing-guide`.
3. Populate `related` with ids that resolve.
4. Run `/catalogue-lint --atoms`.
5. Open the pull request. Reviewers use `atom-review`.

For a batch of the same type, dispatch the `atom-author` agent instead of running this repeatedly.
