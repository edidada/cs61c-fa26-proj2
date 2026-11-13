#!/usr/bin/env bash
set -euo pipefail
mkdir -p evidence
curl --fail --location --retry 3 --max-time 180 https://inst.eecs.berkeley.edu/~cs61c/su24/tools/venus-latest.jar -o tools/venus.jar
sha256sum tools/venus.jar | tee evidence/venus.sha256
java -version 2> evidence/java-version.txt
git rev-parse HEAD > evidence/commit.txt
timeout 900 bash test.sh all -mc 2>&1 | tee evidence/original.log
timeout 300 bash test.sh coverage -mc 2>&1 | tee evidence/coverage.log
python3 - <<'PY'
import re
from pathlib import Path
text=Path('evidence/coverage.log').read_text()
rows=re.findall(r'Coverage for `([^`]+)`: (\d+)/(\d+)',text)
assert len(rows)==4, rows
assert all(int(a)==int(b) and int(b)>0 for _,a,b in rows), rows
print('All four supplied routines have complete instruction coverage:',rows)
PY
