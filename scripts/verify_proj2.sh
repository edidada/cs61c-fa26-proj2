#!/usr/bin/env bash
set -euo pipefail
mkdir -p evidence
curl --fail --location --retry 3 --max-time 180 https://inst.eecs.berkeley.edu/~cs61c/su24/tools/venus-latest.jar -o tools/venus.jar
echo "69e48a8ffecb155d1227d171ae6888be0d3e103975d04b19762a08fc9463e1cc  tools/venus.jar" | sha256sum --check
sha256sum tools/venus.jar | tee evidence/venus.sha256
java -version 2> evidence/java-version.txt
git rev-parse HEAD > evidence/commit.txt
timeout 900 bash test.sh all 2>&1 | tee evidence/original.log
timeout 300 bash test.sh coverage 2>&1 | tee evidence/coverage.log
python3 - <<'PY'
import re
from pathlib import Path
text=Path('evidence/coverage.log').read_text()
rows=re.findall(r'Coverage for `([^`]+)`: (\d+)/(\d+)',text)
assert len(rows)==4, rows
assert all(int(a)==int(b) and int(b)>0 for _,a,b in rows), rows
print('All four supplied routines have complete instruction coverage:',rows)
PY

timeout 300 python3 unittests.py -v TestAbs TestRelu TestArgmax TestDot TestMatmul TestWriteMatrix TestChain -- -mc 2>&1 | tee evidence/memcheck.log
bash scripts/check_proj2.sh 2>&1 | tee evidence/oracle.log
