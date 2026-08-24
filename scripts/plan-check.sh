#!/bin/sh
# Fails when the plan has changed but the manifest or the compiled skills have not.
# Run in CI and before any plugin release. No deps beyond shasum and grep.
set -e
cd "$(dirname "$0")/.."

plan=$(sed -n 's/.*"plan_path": "\([^"]*\)".*/\1/p' manifest.json)
want=$(sed -n 's/.*"plan_hash": "sha256:\([^"]*\)".*/\1/p' manifest.json)
ver=$(sed -n 's/.*"plan_version": "\([^"]*\)".*/\1/p' manifest.json)
have=$(shasum -a 256 "$plan" | cut -d' ' -f1)
fail=0

if [ "$have" != "$want" ]; then
  echo "FAIL plan changed but manifest.json was not bumped"
  echo "  plan:     $plan"
  echo "  manifest: sha256:$want (plan_version $ver)"
  echo "  actual:   sha256:$have"
  echo "  fix: copy the old plan into plan-history/, bump plan_version and plan_hash,"
  echo "       recompile the four plan-derived skills, set breaking if a principle,"
  echo "       a date, an owner or a done criterion changed."
  fail=1
else
  echo "ok   plan matches manifest, plan_version $ver"
fi

for s in $(sed -n 's/^    "\([a-z-]*\)".*/\1/p' manifest.json); do
  f="plugin/skills/$s/SKILL.md"
  got=$(sed -n 's/^plan_version: *//p' "$f")
  if [ "$got" != "$ver" ]; then
    echo "FAIL $s stamped plan_version '$got', manifest says '$ver'"
    fail=1
  else
    echo "ok   $s built from plan_version $got"
  fi
done

exit $fail
