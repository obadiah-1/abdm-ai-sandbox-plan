#!/usr/bin/env python3
"""Validate agent frontmatter.

`claude plugin validate ./plugin` walks skills and commands but not agents,
and the CLI cannot validate a bare component directory, so we check agents here.
"""
import glob
import sys

import yaml

REQUIRED = {"name", "description"}

failures = []
files = sorted(glob.glob("plugin/agents/*.md"))
if not files:
    failures.append("plugin/agents: no agent files found")

for path in files:
    lines = open(path).read().split("\n")
    if lines[0].strip() != "---":
        failures.append(f"{path}: no frontmatter")
        continue
    try:
        end = lines.index("---", 1)
    except ValueError:
        failures.append(f"{path}: unterminated frontmatter")
        continue
    try:
        data = yaml.safe_load("\n".join(lines[1:end]))
    except yaml.YAMLError as exc:
        failures.append(f"{path}: YAML parse failed: {exc}")
        continue
    if not isinstance(data, dict) or not data:
        failures.append(f"{path}: frontmatter is not a mapping")
        continue
    missing = REQUIRED - set(data)
    if missing:
        failures.append(f"{path}: missing {', '.join(sorted(missing))}")

if failures:
    print("\n".join(failures))
    sys.exit(1)
print(f"ok {len(files)} agents")
