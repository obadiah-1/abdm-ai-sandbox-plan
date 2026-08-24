---
description: Run every mechanised check against the ABDM Catalogue and explain each failure.
argument-hint: '[--atoms|--oas|--compiled|--fix] [path]'
---

Run every mechanised check against the ABDM Catalogue and explain each failure. Load the `catalogue-linting` skill for the rule reference. Flags and paths: `$ARGUMENTS`. With no arguments, run everything.

Everything CI runs, locally, before you push.

## Usage

```
/catalogue-lint                 # everything
/catalogue-lint --atoms         # schema, sections, prose, graph, sources
/catalogue-lint --oas           # Spectral over the three specs
/catalogue-lint --compiled      # post-compile validation
/catalogue-lint --fix           # only the mechanically safe fixes
/catalogue-lint <path>          # one file or directory
```

## What `--fix` will do

Section ordering, whitespace, em dash replacement with the correct punctuation, frontmatter key ordering.

## What `--fix` will never do

Write prose, resolve a dangling link, change a verification status, add a source, or invent an identifier. Anything that touches meaning is yours.

## Output

Grouped by rule, with the file, line and the specific fix. Failures first, warnings after.

Two failures deserve special attention when you see them:

- `schema.verified-evidence` means an atom claims verification with no recorded response. Treat as a blocker regardless of what else is red.
- `compile.identifier-diff` means the prose pass invented something. Regenerate. Do not add the token to the Catalogue to clear the build.

Full rule reference and fixes: `catalogue-linting` skill.
