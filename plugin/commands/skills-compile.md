---
description: Compile ABDM Catalogue atoms into agent skills, validate the output, and report which atoms fed which skill.
argument-hint: '[<skill>|--milestone <M>|--validate-only|--trace <skill>]'
---

Compile ABDM Catalogue atoms into skills. Load the `skill-compiler` skill and follow its pipeline. Target: `$ARGUMENTS`. With no arguments, compile everything.

Run the build that produces the skills, the index and the plugin.

## Usage

```
/skills-compile                      # everything
/skills-compile <skill-name>          # one skill
/skills-compile --milestone M2        # the build, test and debug set for M2
/skills-compile --validate-only       # check current output without regenerating
/skills-compile --trace <skill>       # which atoms produced which sections
```

## Sequence

Select, assemble, prose pass, validate, index, bundle. The index is always generated last because it walks everything else.

## Output

- Skills compiled, with the atom count feeding each
- The traceability map from `--trace`
- Validation failures with the atom or template at fault
- Warnings: flows with no skill target, stale atoms compiled with a warning line, orphan atoms
- The new `catalogue_version`

## On failure

The build stops. Nothing publishes. Common causes and where to look:

| Failure | Look at |
|---|---|
| Identifier diff | The prose pass invented a token. Regenerate. Do not add it to the Catalogue. |
| Missing exit condition | The atom's section 4 is not observable. Fix the atom. |
| Missing loop limit | Template bug. See `ooda-skill-authoring`. |
| Gateway coverage zero | A gateway has no verified atoms. This is P1 working. |

## Never

Never hand-edit a file under the compiled skills output. It is overwritten on the next build and the edit is lost silently, which is worse than losing it loudly.
