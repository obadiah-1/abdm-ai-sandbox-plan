---
description: Fetch and hash NHA sources, diff against stored hashes, and open a pull request flipping affected ABDM Catalogue atoms to stale.
argument-hint: '[<source>|--hash <url>|--dry-run]'
---

Sweep the configured ABDM sources for changes. Load the `update-pipeline` skill. Target: `$ARGUMENTS`. With no arguments, check every configured source, including the plan.

The manual version of what the watcher does daily. Run it before a release, or when NHA has announced something.

## Usage

```
/source-check                        # every configured source
/source-check <source-name>          # one
/source-check --hash <url>           # just compute a hash, for adding a source by hand
/source-check --dry-run              # report changes without opening a pull request
```

## What it does

Fetches each source exactly as served, hashes the raw bytes, compares to the stored hash. On a change: identifies affected atoms, flips them to stale, drafts mechanical edits, and opens one pull request per source.

## Read the unreachable list first

A source that could not be fetched is reported at the top, separately from unchanged sources. This distinction matters more than it looks: treating a fetch failure as no change is how a Catalogue silently goes stale while appearing to be watched.

## What it will not do

- Merge anything
- Edit a verified atom's content to match a new source
- Narrow the affected set to reduce review load

Over-flagging costs a review. Under-flagging ships something untrue.

## Breaking changes

Anything that looks like a change to an endpoint contract is called out separately at the top of the report, because those need a person now rather than in the review queue.
