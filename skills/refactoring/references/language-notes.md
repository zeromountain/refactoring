# 언어·생태계별 적용 노트 (Language Notes)

> 이 파일은 책의 내용이 아니라 **책의 기법을 각 언어 관용구로 옮길 때의 공학적 지식**이다.
> 책은 JavaScript로 예시를 들지만 기법은 언어 중립이며, 파울러도 "언어에 따라 절차가 달라진다"고 말한다.

## 공통: 기법 → 언어 기능 대응표

| 책의 기법 | 언어가 제공하는 직접 수단 |
|---|---|
| 변수/레코드 캡슐화(6.6, 7.1) | TS `private`/`readonly`·getter; Python `@property`·`_name` 관례·`dataclass(frozen=True)`; Java/Kotlin `private` + 접근자, Kotlin `val`, Java `record`; Go 소문자 식별자(패키지 비공개); Rust `pub(crate)`·불변 기본; C# 프로퍼티·`init`·`record` |
| 컬렉션 캡슐화(7.2) | TS `ReadonlyArray<T>`/`readonly`; Python `tuple`/`frozenset`/`Sequence` 반환; Java `List.copyOf`·`Collections.unmodifiableList`; Kotlin `List`(읽기 전용) vs `MutableList`; Go 슬라이스는 항상 복사해서 반환; Rust `&[T]`/`Vec` 소유권으로 자연 해결; C# `IReadOnlyList<T>` |
| 세터 제거·참조를 값으로(11.7, 9.4) | TS `readonly` + `Object.freeze`; Python `frozen dataclass`·`NamedTuple`; Kotlin `data class` + `val` + `copy()`; Java `record`; Rust 기본 불변, `#[derive(PartialEq, Eq, Hash)]`; C# `record` + `with` |
| 기본형을 객체로(7.3) | TS branded type(`type Email = string & {__brand:'Email'}`) 또는 클래스; Python `NewType`·`dataclass`; Kotlin `value class`; Rust newtype `struct Meters(f64)`; Go 명명 타입 `type Meters float64` + 메서드; C# `record struct` |
| 조건부 로직을 다형성으로(10.4) | 서브클래스 외에 **인터페이스 구현체**(Go·Java·TS), **sealed class/interface + when/switch**(Kotlin·Java 17+·C#), **enum/sum type + match**(Rust·Swift·TS discriminated union), **전략 객체 맵**(`{gold: goldPricing}`) |
| 생성자를 팩터리 함수로(11.8) | Python `@classmethod`; Kotlin companion `fun of()`·`invoke`; Java static factory; Go `NewX()` 관례(이미 팩터리); Rust `impl X { fn new() }`·builder |
| 함수를 명령으로(11.9) | 일급 함수·클로저가 있으면 대체로 불필요. Java(람다 이전 코드)·C#에서 여전히 유용. 되돌리기(undo)·큐잉이 필요할 때만 |
| 매개변수 객체(6.8) | TS 객체 리터럴 + 인터페이스; Python `dataclass`; Kotlin `data class`·named args(작은 경우 대체); Go struct; Rust struct·builder |
| 플래그 인수 제거(11.3) | Kotlin/Python named args가 있으면 냄새가 약해지지만, 함수 안 `if (flag)` 분기가 남는 문제는 그대로다. 분기가 크면 여전히 함수를 나눈다 |
| 어서션 추가(10.6) | Python `assert`(`-O`에서 제거됨); Java `assert`(기본 비활성); TS `asserts x is T` 함수; Rust `debug_assert!`; Go 관용 없음 → `panic` 또는 안 함 |

## 오류 처리 기법은 언어 관용을 따른다

- **11.12 오류 코드를 예외로**는 예외가 관용인 언어(Java·Python·C#·TS·Kotlin)에서 유효하다.
- **Go**에서는 반대다. `error` 값 반환이 관용이고 `panic`은 프로그래머 오류에만 쓴다. 여기서 "오류 코드 냄새"의 처방은 `-1`/`nil` 같은 센티널을 **`error` 타입**으로, 문자열 비교를 **`errors.Is/As`** 로, 문맥은 `fmt.Errorf("...: %w", err)` 로 감싸는 것이다.
- **Rust**에서는 `Result<T, E>` + `?`. 센티널·`Option` 남용을 `Result`로, 문자열 에러를 `thiserror` 타입으로. `unwrap()`은 어서션(10.6)의 자리.
- **TS/Kotlin에서 Result 타입을 쓰는 코드베이스**라면 그 관용을 존중한다. 예외로 바꾸지 않는다.
- **11.13 예외를 사전확인으로**는 모든 언어에서 유효하다. 흐름 제어용 예외는 어디서나 악취.

## 상속이 없거나 약한 언어에서의 12장

- **Go**: 상속이 없다. 12.x 대부분은 "임베딩 → 인터페이스 + 구성"으로 읽는다. 타입 코드를 서브클래스로(12.6) = 인터페이스 정의 + 타입별 구현 struct + 팩터리. 슈퍼클래스 추출(12.8) = 공통 인터페이스 추출 또는 공통 struct 임베딩.
- **Rust**: trait + impl. 서브클래스를 위임으로(12.10)는 기본 상태에 가깝다. 다형성은 `enum` + `match`(닫힌 집합) 또는 `dyn Trait`(열린 집합) 중 선택 — 변형이 자주 추가되면 trait, 연산이 자주 추가되면 enum.
- **함수형 스타일(TS/Kotlin/Scala/FP)**: 조건부 로직 → 다형성 대신 **discriminated union + exhaustive switch**. 컴파일러가 누락 분기를 잡아 주므로 "반복되는 switch"의 위험이 줄지만, **같은 switch가 여러 파일에 반복**되면 여전히 냄새 → 연산을 한곳(모듈)으로 모으거나 다형성으로.
- 상속이 있는 언어에서도 "상속을 먼저, 문제가 생기면 위임" 원칙은 유지(12.10 배경). 다만 React 컴포넌트, Go, Rust처럼 생태계가 구성(composition)을 기본으로 삼으면 처음부터 위임/구성.

## 도구가 안전하게 해 주는 기법 (LSP/IDE)

| 생태계 | 도구 | 안전한 자동 리팩터링 |
|---|---|---|
| TS/JS | tsserver (VS Code·Cursor), WebStorm | rename(6.5·6.7·9.2), extract function/constant(6.1·6.3), inline(6.2·6.4), move to file, convert to named parameters(6.8 유사) |
| Python | pyright/pylance, rope, PyCharm | rename, extract method/variable, inline, move. 동적 속성·`getattr`는 못 잡는다 |
| Java/Kotlin | IntelliJ IDEA, Eclipse JDT | 가장 완전: rename, extract/inline, move, change signature, pull up/push down, extract interface/superclass, introduce parameter object, replace constructor with factory |
| Go | gopls | rename, extract function/variable, inline call. 인터페이스 추출은 수동 |
| Rust | rust-analyzer | rename, extract function/variable, inline, generate impl, convert match ↔ if-let |
| C# | Roslyn (VS·Rider) | rename, extract, inline, change signature, pull up, extract interface/base class |

도구 리팩터링은 **테스트 없이도 비교적 안전**하다(2.10). 그러나 도구가 못 보는 것(문자열 참조, 리플렉션, 다른 저장소)은 여전히 `safety.md`의 호출자 찾기 절차가 필요하다. 도구가 없는 환경(CLI 에이전트)에서는 절차의 각 단계를 손으로 하고 단계마다 타입 검사를 돌리는 것이 도구를 대신한다.

## 언어별 흔한 함정

- **JS/TS**: `this` 바인딩 — 메서드를 함수로 추출하거나 옮길 때 화살표 함수/바인딩 확인. 옵셔널 체이닝(`a?.b`)이 특이 케이스(10.5)를 대체하는 것처럼 보이지만 `?.`가 여러 곳에 반복되면 그게 바로 특이 케이스 객체가 필요한 신호.
- **Python**: 가변 기본 인수, `@property`로 바꿀 때 호출 괄호 제거 누락, 순환 import(함수 옮기기 8.1 시).
- **Java/Kotlin**: `equals/hashCode` 없는 값 객체(9.4), 체크 예외 시그니처 전파(11.12), Kotlin `data class`의 `copy`가 세터 대체.
- **Go**: 값 리시버 vs 포인터 리시버(함수 옮기기 시 변경 여부), 인터페이스는 사용하는 쪽 패키지에 정의, 슬라이스·맵 반환은 항상 별칭 문제.
- **Rust**: 소유권 때문에 함수 추출(6.1)에서 매개변수가 `&T`/`&mut T`/`T` 중 무엇인지 결정해야 함. 임시 변수를 질의 함수로(7.4)는 빌림 규칙과 충돌할 수 있어 클로저나 메서드로.
- **모든 언어**: 순수 함수는 어디로든 옮길 수 있고 몇 번이든 호출할 수 있다. 부작용이 있는 함수는 그렇지 않다 — 질의/변경 분리(11.1)가 다른 모든 기법의 문을 연다.
