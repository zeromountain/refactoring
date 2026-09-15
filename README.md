# refactoring

마틴 파울러 『리팩터링 2판』(Refactoring, 2nd ed.)을 AI 코딩 에이전트용 스킬로 정리한 플러그인입니다.
Claude Code와 OpenAI Codex 양쪽에서 같은 스킬(`skills/refactoring/`)을 설치해 쓸 수 있습니다.

- 2장 원칙 (정의, 두 개의 모자, 언제 리팩터링할지, YAGNI, 성능) · 4장 테스트 구축
- 3장 악취 24개와 부록 B 악취→기법 처방
- 6~12장 기법 66개 카탈로그: 배경 → 절차 → 예시, 한국어·영어 이름 병기
- 실무 층: 기법 연쇄 레시피(R1~R10 + 끝까지 가는 예시), 안전 프로토콜(특성화 테스트·호출자 찾기·회색 지대), 판단 기준(우선순위·멈출 때·과잉 리팩터링 신호), 언어별 적용 노트(TS/Python/Java/Kotlin/Go/Rust/C#), 대규모 변경 패턴(병렬 변경·추상화로 갈아타기·교살자)

## 설치

### Claude Code

```
/plugin marketplace add zeromountain/refactoring
/plugin install refactoring@zeromountain
```

CLI에서도 같은 명령을 쓸 수 있습니다: `claude plugin marketplace add zeromountain/refactoring` → `claude plugin install refactoring@zeromountain`.

> 마켓플레이스는 GitHub 저장소 단축 표기(`owner/repo`)나 Git URL로 추가하세요. `marketplace.json` 파일의 raw URL로 추가하면 상대 경로 소스가 해석되지 않습니다.

### Codex

```
codex plugin marketplace add zeromountain/refactoring
codex plugin add refactoring@zeromountain
```

Codex 공식 플러그인 디렉터리(앱 내 브라우저)에는 아직 셀프서비스 등록이 열려 있지 않아, 위처럼 커스텀 마켓플레이스로 추가해야 합니다.

## 사용

설치 후 "리팩터링해줘", "이 함수 너무 길어", "코드 냄새 나", "refactor this" 같은 요청이나 기법 이름(함수 추출하기, Replace Temp with Query …)이 나오면 스킬이 동작합니다.
두 가지 모드가 있습니다.
- **진단**: "리뷰해줘", "뭘 고쳐야 해?", "계획 세워줘" → 코드를 수정하지 않고 악취 보고서(위치·근거·기법 순서·위험)를 냅니다.
- **적용**: "리팩터링해줘" → 테스트 확인 → 악취 진단 → 레시피 선택 → 절차 한 단계 + 매번 테스트 순서로 진행하고, 리팩터링과 기능 변경을 한 커밋에 섞지 않습니다.

인수로 모드와 기법을 지정할 수도 있습니다: `/refactoring 진단 src/pricing.ts`, `/refactoring 적용 7.4 src/pricing.ts`.

### 검증 에이전트 (Claude Code 전용)

적용 모드가 끝나면 스킬은 `refactoring:refactoring-verifier` 서브에이전트에 diff 기준(시작 커밋 또는 "작업 트리")을 넘겨 독립 검증을 받습니다. 이 에이전트는 읽기 전용이며, 순수 이동·이름 변경·추출로 설명되지 않는 줄을 찾아 평가 순서·부동소수점·예외 타입·공개 API 같은 회색 지대로 분류해 표로 돌려줍니다. Codex에는 서브에이전트가 없어 스킬이 같은 점검을 스스로 합니다.

### 편집 후 테스트 자동 실행 (선택, Claude Code)

플러그인은 훅을 싣지 않습니다 — 테스트 명령이 프로젝트마다 달라서입니다. 편집마다 테스트를 돌리고 싶으면 프로젝트의 `.claude/settings.json`에 직접 거세요.

```json
{
  "hooks": {
    "PostToolUse": [
      { "matcher": "Edit|Write",
        "hooks": [{ "type": "command",
                    "command": "npm test --silent >/dev/null 2>&1 || { npm test 2>&1 | tail -20 >&2; exit 2; }" }] }
    ]
  }
}
```

훅은 종료 코드 2로 끝나야 stderr 가 에이전트에게 전달됩니다 — 통과하면 조용히 0, 실패하면 마지막 20줄을 stderr 로 보내고 2로 끝나는 구조입니다.

## 저장소 구조

```
plugin.json                       Codex 플러그인 매니페스트 (Agent Plugins 포터블 형식)
.agents/plugins/marketplace.json  Codex 마켓플레이스 (플러그인 소스 = 저장소 루트)
.claude-plugin/plugin.json        Claude Code 플러그인 매니페스트
.claude-plugin/marketplace.json   Claude Code 마켓플레이스 (플러그인 소스 = 저장소 루트)
skills/refactoring/SKILL.md       스킬 진입점
skills/refactoring/references/    원칙 · 악취 · 기법 카탈로그 (장별 파일) · 레시피 · 안전 · 판단 · 언어 노트
agents/refactoring-verifier.md    diff 독립 검증 서브에이전트 (Claude Code 전용)
scripts/check.sh, bump.sh         불변식 검사 · 버전 일괄 갱신
evals/                            claude plugin eval 케이스 6개
```

## 검증

`scripts/check.sh` 가 문서 불변식(기법 66개, 절 번호 참조, 버전 일치, 매니페스트)을 검사합니다.

`evals/`에 `claude plugin eval` 케이스 여섯 개가 있습니다 — 진단 모드 3개(계획만 요청, 리팩터링+기능 분리, Python 관용)와 적용 모드 3개(기법 이름 지목, 테스트 없는 코드, 공개 API 회색 지대).
- 진단 모드 3개만 (어디서나): `claude plugin eval . --tag diagnosis --scaffold --allow-tools Edit Write --runs 1 --ablation none --no-publish`
- 전체 6개: `claude plugin eval . --scaffold --allow-tools Edit Write Bash --runs 1 --ablation none --no-publish --max-cost-usd 8`

적용 모드 케이스는 Bash 권한이 필요한데, `~/.docker` 안에 심링크가 있는 머신(Docker Desktop 기본 배치)에서는 eval 샌드박스가 Bash 권한을 거부하므로 Docker Desktop 이 없는 머신이나 CI 에서 돌려야 합니다.

## 출처

Martin Fowler, *Refactoring: Improving the Design of Existing Code*, 2nd ed. (2018) / 『리팩터링 2판』(한빛미디어).
기법 목록·별칭·반대 기법은 refactoring.com/catalog, 악취별 처방은 출판사가 공개한 3장 원문을 근거로 했습니다.
본문은 요약이며 책의 문장을 옮기지 않았습니다.
