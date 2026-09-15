#!/bin/bash
# 유일한 악취가 공개 API 의 플래그 인수인 픽스처. git 저장소로 초기화한다.
set -e
d="$(dirname "$0")"
cp "$d/pricing.js" "$d/pricing.test.js" "$d/index.d.ts" "$d/README.md" "$d/package.json" .
git init -q
git -c user.name=eval -c user.email=eval@example.com add -A
git -c user.name=eval -c user.email=eval@example.com commit -qm fixture
