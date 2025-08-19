#!/usr/bin/env bash
set -euo pipefail
PY=${1:-python}
$PY -m pip install -r "$(dirname "$0")/../etl/requirements.txt"
$PY "$(dirname "$0")/../etl/generate_and_load.py"
