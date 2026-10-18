#!/bin/bash
set -euo pipefail

# Query official Unraid release index
JSON="$(curl -fsSL --retry 3 --connect-timeout 15 "https://releases.unraid.net/json?includePublic=1")"

python3 -c "
import sys, json
data = json.loads(sys.stdin.read())
stable = [x['version'] for x in data if '-' not in x.get('version', '') and x.get('published')]
if stable:
    print(stable[0])
else:
    sys.exit(1)
" <<< "$JSON"
