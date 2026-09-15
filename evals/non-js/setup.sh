#!/bin/bash
# Python 픽스처 (TS 픽스처와 같은 냄새). 진단 모드이므로 git 초기화는 불필요.
set -e
d="$(dirname "$0")"
cp "$d/invoice.py" "$d/test_invoice.py" .
