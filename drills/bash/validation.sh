#!/usr/bin/env bash

#| Option     | Meaning                                 |
#| ---------- | --------------------------------------- |
#| `-u`       | Fail on missing variables               |
#| `-e`       | Fail on command errors                  |
#| `pipefail` | Fail if any command in a pipeline fails |

set -euo pipefail

if [[ -z "${AWS_REGION:-}" ]]; then
    echo "AWS_REGION is required" >&2
    exit 1
fi

# trap and cleanup
cleanup() {
    rm -rf "$TMPDIR"
    echo "Cleaned up $TMPDIR"
}

TMPDIR=$(mktemp -d)
trap cleanup EXIT