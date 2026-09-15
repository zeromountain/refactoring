#!/bin/bash
# 테스트가 없는 픽스처. git 저장소로 초기화해 절차 1(git status)·절차 6(git diff 점검)이 돌아가게 한다.
set -e
d="$(dirname "$0")"
cp "$d/fees.js" "$d/package.json" .
git init -q
git -c user.name=eval -c user.email=eval@example.com add -A
git -c user.name=eval -c user.email=eval@example.com commit -qm fixture
