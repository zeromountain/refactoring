# 부록 A 리팩터링 목록 (한국어 ↔ 영어, 66개)

『리팩터링 2판』 목차 순서. 각 항목의 절차와 예시는 해당 `catalog-*.md` 파일에 있다.
영어 이름은 refactoring.com/catalog 기준. "1판:"은 통합·개명된 1판 기법 이름.

## 6장 기본적인 리팩터링 → `catalog-basic.md`
| 절 | 한국어 | English | 비고 |
|---|---|---|---|
| 6.1 | 함수 추출하기 | Extract Function | 1판: Extract Method · ↔ 6.2 |
| 6.2 | 함수 인라인하기 | Inline Function | 1판: Inline Method · ↔ 6.1 |
| 6.3 | 변수 추출하기 | Extract Variable | 1판: Introduce Explaining Variable · ↔ 6.4 |
| 6.4 | 변수 인라인하기 | Inline Variable | 1판: Inline Temp · ↔ 6.3 |
| 6.5 | 함수 선언 바꾸기 | Change Function Declaration | 1판: Rename Method, Add/Remove Parameter, Change Signature |
| 6.6 | 변수 캡슐화하기 | Encapsulate Variable | 1판: Encapsulate Field, Self-Encapsulate Field |
| 6.7 | 변수 이름 바꾸기 | Rename Variable | |
| 6.8 | 매개변수 객체 만들기 | Introduce Parameter Object | |
| 6.9 | 여러 함수를 클래스로 묶기 | Combine Functions into Class | 2판 신규 |
| 6.10 | 여러 함수를 변환 함수로 묶기 | Combine Functions into Transform | 2판 신규 |
| 6.11 | 단계 쪼개기 | Split Phase | 2판 신규 |

## 7장 캡슐화 → `catalog-encapsulation.md`
| 절 | 한국어 | English | 비고 |
|---|---|---|---|
| 7.1 | 레코드 캡슐화하기 | Encapsulate Record | 1판: Replace Record with Data Class |
| 7.2 | 컬렉션 캡슐화하기 | Encapsulate Collection | |
| 7.3 | 기본형을 객체로 바꾸기 | Replace Primitive with Object | 1판: Replace Data Value with Object, Replace Type Code with Class |
| 7.4 | 임시 변수를 질의 함수로 바꾸기 | Replace Temp with Query | |
| 7.5 | 클래스 추출하기 | Extract Class | ↔ 7.6 |
| 7.6 | 클래스 인라인하기 | Inline Class | ↔ 7.5 |
| 7.7 | 위임 숨기기 | Hide Delegate | ↔ 7.8 |
| 7.8 | 중개자 제거하기 | Remove Middle Man | ↔ 7.7 |
| 7.9 | 알고리즘 교체하기 | Substitute Algorithm | |

## 8장 기능 이동 → `catalog-moving-features.md`
| 절 | 한국어 | English | 비고 |
|---|---|---|---|
| 8.1 | 함수 옮기기 | Move Function | 1판: Move Method |
| 8.2 | 필드 옮기기 | Move Field | |
| 8.3 | 문장을 함수로 옮기기 | Move Statements into Function | ↔ 8.4 |
| 8.4 | 문장을 호출한 곳으로 옮기기 | Move Statements to Callers | ↔ 8.3 |
| 8.5 | 인라인 코드를 함수 호출로 바꾸기 | Replace Inline Code with Function Call | |
| 8.6 | 문장 슬라이드하기 | Slide Statements | 1판: Consolidate Duplicate Conditional Fragments |
| 8.7 | 반복문 쪼개기 | Split Loop | |
| 8.8 | 반복문을 파이프라인으로 바꾸기 | Replace Loop with Pipeline | 2판 신규 |
| 8.9 | 죽은 코드 제거하기 | Remove Dead Code | |

## 9장 데이터 조직화 → `catalog-organizing-data.md`
| 절 | 한국어 | English | 비고 |
|---|---|---|---|
| 9.1 | 변수 쪼개기 | Split Variable | 1판: Split Temp, Remove Assignments to Parameters |
| 9.2 | 필드 이름 바꾸기 | Rename Field | |
| 9.3 | 파생 변수를 질의 함수로 바꾸기 | Replace Derived Variable with Query | |
| 9.4 | 참조를 값으로 바꾸기 | Change Reference to Value | ↔ 9.5 |
| 9.5 | 값을 참조로 바꾸기 | Change Value to Reference | ↔ 9.4 |
| 9.6 | 매직 리터럴 바꾸기 | Replace Magic Literal | 1판: Replace Magic Number with Symbolic Constant |

## 10장 조건부 로직 간소화 → `catalog-conditional-logic.md`
| 절 | 한국어 | English | 비고 |
|---|---|---|---|
| 10.1 | 조건문 분해하기 | Decompose Conditional | |
| 10.2 | 조건식 통합하기 | Consolidate Conditional Expression | |
| 10.3 | 중첩 조건문을 보호 구문으로 바꾸기 | Replace Nested Conditional with Guard Clauses | |
| 10.4 | 조건부 로직을 다형성으로 바꾸기 | Replace Conditional with Polymorphism | |
| 10.5 | 특이 케이스 추가하기 | Introduce Special Case | 1판: Introduce Null Object |
| 10.6 | 어서션 추가하기 | Introduce Assertion | |
| 10.7 | 제어 플래그를 탈출문으로 바꾸기 | Replace Control Flag with Break | 1판: Remove Control Flag |

## 11장 API 리팩터링 → `catalog-apis.md`
| 절 | 한국어 | English | 비고 |
|---|---|---|---|
| 11.1 | 질의 함수와 변경 함수 분리하기 | Separate Query from Modifier | |
| 11.2 | 함수 매개변수화하기 | Parameterize Function | 1판: Parameterize Method |
| 11.3 | 플래그 인수 제거하기 | Remove Flag Argument | 1판: Replace Parameter with Explicit Methods |
| 11.4 | 객체 통째로 넘기기 | Preserve Whole Object | |
| 11.5 | 매개변수를 질의 함수로 바꾸기 | Replace Parameter with Query | 1판: Replace Parameter with Method · ↔ 11.6 |
| 11.6 | 질의 함수를 매개변수로 바꾸기 | Replace Query with Parameter | ↔ 11.5 |
| 11.7 | 세터 제거하기 | Remove Setting Method | |
| 11.8 | 생성자를 팩터리 함수로 바꾸기 | Replace Constructor with Factory Function | 1판: …with Factory Method |
| 11.9 | 함수를 명령으로 바꾸기 | Replace Function with Command | 1판: Replace Method with Method Object · ↔ 11.10 |
| 11.10 | 명령을 함수로 바꾸기 | Replace Command with Function | ↔ 11.9 |
| 11.11 | 수정된 값 반환하기 | Return Modified Value | 2판 신규 |
| 11.12 | 오류 코드를 예외로 바꾸기 | Replace Error Code with Exception | |
| 11.13 | 예외를 사전확인으로 바꾸기 | Replace Exception with Precheck | 1판: Replace Exception with Test |

## 12장 상속 다루기 → `catalog-inheritance.md`
| 절 | 한국어 | English | 비고 |
|---|---|---|---|
| 12.1 | 메서드 올리기 | Pull Up Method | ↔ 12.4 |
| 12.2 | 필드 올리기 | Pull Up Field | ↔ 12.5 |
| 12.3 | 생성자 본문 올리기 | Pull Up Constructor Body | |
| 12.4 | 메서드 내리기 | Push Down Method | ↔ 12.1 |
| 12.5 | 필드 내리기 | Push Down Field | ↔ 12.2 |
| 12.6 | 타입 코드를 서브클래스로 바꾸기 | Replace Type Code with Subclasses | 1판: Extract Subclass, Replace Type Code with State/Strategy · ↔ 12.7 |
| 12.7 | 서브클래스 제거하기 | Remove Subclass | 1판: Replace Subclass with Fields · ↔ 12.6 |
| 12.8 | 슈퍼클래스 추출하기 | Extract Superclass | |
| 12.9 | 계층 합치기 | Collapse Hierarchy | |
| 12.10 | 서브클래스를 위임으로 바꾸기 | Replace Subclass with Delegate | 2판 신규 |
| 12.11 | 슈퍼클래스를 위임으로 바꾸기 | Replace Superclass with Delegate | 1판: Replace Inheritance with Delegation |

---

## 출처
- Martin Fowler, *Refactoring: Improving the Design of Existing Code*, 2nd ed. (Addison-Wesley, 2018) / 『리팩터링 2판』(한빛미디어, 2020, 개앞맵시·남기혁 옮김)
- refactoring.com/catalog — 66개 기법 목록, 스케치, 별칭, 반대 기법 (2026-09-15 확인)
- InformIT 샘플 챕터 "When to Start Refactoring Code—and When to Stop" (3장 전문) — 악취별 처방의 근거
- martinfowler.com bliki: DefinitionOfRefactoring, RefactoringMalapropism, OpportunisticRefactoring, WorkflowsOfRefactoring, DesignStaminaHypothesis, Yagni, SelfTestingCode
- martinfowler.com/articles/refactoring-2nd-changes.html — 1판→2판 기법 이름 변경 표
