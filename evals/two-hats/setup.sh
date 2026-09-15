#!/bin/bash
# 평가 작업 디렉터리에 냄새 나는 샘플 파일을 만든다 (claude plugin eval --scaffold 로 실행됨).
set -e
cp "$(dirname "$0")/invoice.ts" ./invoice.ts
