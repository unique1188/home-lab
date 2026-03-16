#!/usr/bin/env bash
set -euo pipefail

if command -v op >/dev/null 2>&1; then
  if op whoami >/dev/null 2>&1; then
    exec op inject
  fi
fi

python3 -c '
import os
import re
import sys

text = sys.stdin.read()
pattern = re.compile(r"op://[^/\s]+/[^/\s]+/([A-Z0-9_]+)")
missing = []

def replace(match):
    key = match.group(1)
    value = os.environ.get(key)
    if value is None:
        missing.append(key)
        return match.group(0)
    return value

rendered = pattern.sub(replace, text)

if missing:
    unique = []
    for key in missing:
        if key not in unique:
            unique.append(key)
    print(
        "Missing environment variables for secret injection: "
        + ", ".join(unique),
        file=sys.stderr,
    )
    sys.exit(1)

sys.stdout.write(rendered)
'
