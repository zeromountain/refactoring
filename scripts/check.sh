#!/usr/bin/env bash
# CLAUDE.md 의 불변식을 검사한다. 실패 항목을 모두 나열한 뒤 exit 1.
set -u
cd "$(dirname "$0")/.."
python3 - <<'PY' || exit 1
import json, re, glob, sys, pathlib
S = pathlib.Path('skills/refactoring'); R = S / 'references'
fail = []
def read(p): return pathlib.Path(p).read_text()

# 0. SKILL.md frontmatter description 은 단일 인용
if not re.search(r"^description: '", read(S / 'SKILL.md'), re.M):
    fail.append("SKILL.md: description 이 단일 인용(')이 아님")

# 1. 카탈로그 헤딩 66개, 중복 없음
heads = []
for f in sorted(glob.glob(str(R / 'catalog-*.md'))):
    if f.endswith('catalog-index.md'): continue
    heads += re.findall(r'^## (\d+\.\d+) ', read(f), re.M)
if len(heads) != 66: fail.append(f"catalog-*.md 헤딩 {len(heads)}개 (66 필요)")
dup = {h for h in heads if heads.count(h) > 1}
if dup: fail.append(f"catalog 헤딩 중복: {sorted(dup)}")
catalog = set(heads)

# 2. catalog-index.md 표와 1:1
index = set(re.findall(r'^\| (\d+\.\d+) \|', read(R / 'catalog-index.md'), re.M))
if index != catalog:
    fail.append(f"catalog-index.md 불일치: index에만 {sorted(index - catalog)}, 헤딩에만 {sorted(catalog - index)}")

# 3. (N.M) 참조 해석 — 카탈로그 헤딩 또는 원칙·악취 절(2.x~5.x)
sections = set(catalog)
for f in [R / 'principles.md', R / 'smells.md']:
    sections |= set(re.findall(r'^#{2,3} (\d+\.\d+)', read(f), re.M))
files = [R / n for n in ('recipes.md', 'safety.md', 'judgment.md', 'language-notes.md', 'large-scale.md')] \
        + [S / 'SKILL.md'] + [pathlib.Path(p) for p in glob.glob('agents/*.md')]
for f in files:
    refs = set()
    for m in re.finditer(r'\((\d+\.\d+)[^)]*\)', read(f)):
        refs |= set(re.findall(r'\d+\.\d+', m.group(0)))
    bad = sorted(refs - sections)
    if bad: fail.append(f"{f}: 해석되지 않는 절 참조 {bad}")

# 4. smells.md 의 처방(→ 줄) 과 부록 B 표의 번호는 전부 카탈로그 헤딩
smells = read(R / 'smells.md')
refs = set(re.findall(r'\((\d+\.\d+)\)', smells))
bad = sorted(refs - catalog)
if bad: fail.append(f"smells.md: 카탈로그에 없는 기법 번호 {bad}")

# 5. 버전 3곳 일치
v1 = json.load(open('plugin.json'))['version']
v2 = json.load(open('.claude-plugin/plugin.json'))['version']
mk = json.load(open('.claude-plugin/marketplace.json'))
v3 = next(p['version'] for p in mk['plugins'] if p['name'] == 'refactoring')
if not (v1 == v2 == v3): fail.append(f"버전 불일치: plugin.json={v1} .claude-plugin/plugin.json={v2} marketplace={v3}")

for x in fail: print("FAIL", x)
print(f"headings={len(heads)} version={v1}")
sys.exit(1 if fail else 0)
PY
claude plugin validate --strict . >/dev/null 2>&1 || { echo "FAIL claude plugin validate --strict ."; exit 1; }
echo OK
