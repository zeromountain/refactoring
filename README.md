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

## 저장소 구조

```
plugin.json                       Codex 플러그인 매니페스트 (Agent Plugins 포터블 형식)
.agents/plugins/marketplace.json  Codex 마켓플레이스 (플러그인 소스 = 저장소 루트)
.claude-plugin/plugin.json        Claude Code 플러그인 매니페스트
.claude-plugin/marketplace.json   Claude Code 마켓플레이스 (플러그인 소스 = 저장소 루트)
skills/refactoring/SKILL.md       스킬 진입점
skills/refactoring/references/    원칙 · 악취 · 기법 카탈로그 (장별 파일)
```

## 검증

`evals/`에 `claude plugin eval` 케이스 두 개가 있습니다(계획만 요청 → 수정 없이 진단 보고서, 리팩터링+기능 요청 → 두 단계로 분리).
`claude plugin eval . --scaffold --allow-tools Edit Write --runs 1 --ablation none --no-publish` 로 실행합니다.

## 출처

Martin Fowler, *Refactoring: Improving the Design of Existing Code*, 2nd ed. (2018) / 『리팩터링 2판』(한빛미디어).
기법 목록·별칭·반대 기법은 refactoring.com/catalog, 악취별 처방은 출판사가 공개한 3장 원문을 근거로 했습니다.
본문은 요약이며 책의 문장을 옮기지 않았습니다.
