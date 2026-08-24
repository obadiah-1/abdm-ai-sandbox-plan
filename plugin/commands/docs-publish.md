---
description: Generate navigation, preview and publish the Scalar documentation site for the ABDM Catalogue.
argument-hint: '[--preview|--nav-only|--check]'
---

Publish the ABDM docs site. Load the `scalar-docs` skill and follow the procedure below. Mode: `$ARGUMENTS`. Default to `--preview` unless the user explicitly asked to publish live, and confirm before any live publish.

## Usage

```
/docs-publish --preview        # preview deployment, the default for a pull request
/docs-publish                  # publish to the live site, main only
/docs-publish --nav-only       # regenerate scalar.config.json navigation and stop
/docs-publish --check          # verify what would publish without publishing
```

## Sequence

1. Generate navigation from atom frontmatter, grouped gateway, then milestone, then type
2. Emit depth labels into the sidebar, not only onto pages
3. Emit verification banners for unverified and stale atoms
4. Stamp `catalogue_version` into the footer
5. Build, then preview or publish

## Preconditions

Publishing to live requires: lint passing, skills compiling and validating, and being on main. A preview deployment requires only that the build succeeds, which is the point of previews.

## Reviewing a preview

Read the rendered page, not the diff. Dummy-proofness is a property of rendered output: whether a banner is visible, whether a diagram makes the sequence obvious, whether a depth label is where a skimming reader will see it.

## Never hand-edit navigation

`scalar.config.json` navigation is a build output. If a page is grouped wrongly, its frontmatter is wrong. Editing the config is the same class of mistake as editing a compiled skill.
