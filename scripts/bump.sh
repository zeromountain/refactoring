#!/usr/bin/env bash
# 버전을 세 매니페스트에 동시에 기록한 뒤 check.sh 를 돌린다.  사용법: scripts/bump.sh 1.2.0
set -eu
cd "$(dirname "$0")/.."
[ $# -eq 1 ] && [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "usage: $0 <major.minor.patch>"; exit 2; }
V="$1" python3 - <<'PY'
import os, re, pathlib
v = os.environ['V']
for p in ('plugin.json', '.claude-plugin/plugin.json', '.claude-plugin/marketplace.json'):
    f = pathlib.Path(p); s = f.read_text()
    s, n = re.subn(r'"version": "\d+\.\d+\.\d+"', f'"version": "{v}"', s)
    assert n == 1, f"{p}: version 필드가 {n}개"
    f.write_text(s)
print("version ->", v)
PY
exec scripts/check.sh
