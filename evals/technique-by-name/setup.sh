#!/bin/bash
# 평가 작업 디렉터리에 픽스처를 만들고 git 저장소로 초기화한다 (claude plugin eval --scaffold 로 실행됨).
# 스킬의 절차 1(git status)·절차 6(git diff 점검)이 실제로 돌아가야 하므로 초기 커밋까지 만든다.
set -e
d="$(dirname "$0")"
cp "$d/report.js" "$d/report.test.js" "$d/package.json" .
git init -q
git -c user.name=eval -c user.email=eval@example.com add -A
git -c user.name=eval -c user.email=eval@example.com commit -qm fixture
