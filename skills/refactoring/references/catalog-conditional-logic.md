# 10장 조건부 로직 간소화 (Simplifying Conditional Logic)

조건부 로직은 프로그램의 힘이지만 복잡도의 주범이다. 분해하고, 통합하고, 보호 구문으로 펴고, 다형성으로 대체한다.

---

## 10.1 조건문 분해하기 (Decompose Conditional)

**배경**
- 복잡한 조건문은 "무슨 일이 일어나는지"는 말해도 "왜"는 말하지 않는다. 조건식과 각 분기를 **의도를 드러내는 이름의 함수**로 추출한다.
- 사실상 함수 추출(6.1)의 특수 사례이지만 너무 자주 쓰여 따로 이름을 붙였다.

**절차**
1. 조건식과 각 조건절(then/else)을 각각 함수로 추출(6.1)한다.
2. 테스트.
- 분기가 단순해지면 삼항 연산자로 정리할 수 있다.

**예시**
```js
// before
if (!aDate.isBefore(plan.summerStart) && !aDate.isAfter(plan.summerEnd))
  charge = quantity * plan.summerRate;
else
  charge = quantity * plan.regularRate + plan.regularServiceCharge;
// after
charge = summer() ? summerCharge() : regularCharge();
function summer() { return !aDate.isBefore(plan.summerStart) && !aDate.isAfter(plan.summerEnd); }
function summerCharge() { return quantity * plan.summerRate; }
function regularCharge() { return quantity * plan.regularRate + plan.regularServiceCharge; }
```

---

## 10.2 조건식 통합하기 (Consolidate Conditional Expression)

**배경**
- 조건은 다른데 결과 동작이 같은 조건문이 연달아 있으면 `and`/`or`로 **하나로 합친다**. 여러 조각이 사실은 **하나의 검사**임이 드러나고, 합친 조건식을 함수로 추출(6.1)해 이름 붙이기 좋아진다.
- 조건들이 독립적이라고 판단되면(정말 별개의 검사) 합치지 않는다.

**절차**
1. 조건식들에 부작용이 없는지 확인(있으면 질의 함수와 변경 함수 분리 11.1 먼저).
2. 조건문 두 개를 논리 연산자로 결합한다(순차 → `or`, 중첩 → `and`).
3. 테스트.
4. 조건이 하나만 남을 때까지 반복.
5. 통합된 조건식을 함수로 추출(6.1)할지 검토.

**예시**
```js
// before
if (anEmployee.seniority < 2) return 0;
if (anEmployee.monthsDisabled > 12) return 0;
if (anEmployee.isPartTime) return 0;
// after
if (isNotEligibleForDisability()) return 0;
function isNotEligibleForDisability() {
  return anEmployee.seniority < 2 || anEmployee.monthsDisabled > 12 || anEmployee.isPartTime;
}
```

---

## 10.3 중첩 조건문을 보호 구문으로 바꾸기 (Replace Nested Conditional with Guard Clauses)

**배경**
- 조건문의 두 형태: (1) 양쪽 모두 정상 동작 → `if/else`, (2) 한쪽만 정상이고 다른 쪽은 비정상/예외 → **보호 구문**(guard clause, 즉시 return).
- 보호 구문은 "이건 이 함수의 핵심이 아니다. 여기까지면 나간다"라고 말한다. **함수 진입점이 하나면 반환점도 하나여야 한다는 규칙은 따르지 않는다** — 명확성이 우선.
- 조건을 **반대로 뒤집어**(`if (!x) return`) 보호 구문으로 만드는 경우가 많다.

**절차**
1. 교체해야 할 조건 중 가장 바깥 것을 선택하여 보호 구문으로 바꾼다.
2. 테스트.
3. 반복.
4. 모든 보호 구문이 같은 결과를 반환하면 조건식 통합(10.2).

**예시**
```js
// before
function payAmount(employee) {
  let result;
  if (employee.isSeparated) result = { amount: 0, reason: 'SEP' };
  else {
    if (employee.isRetired) result = { amount: 0, reason: 'RET' };
    else { /* 급여 계산 */ result = someFinalComputation(); }
  }
  return result;
}
// after
function payAmount(employee) {
  if (employee.isSeparated) return { amount: 0, reason: 'SEP' };
  if (employee.isRetired) return { amount: 0, reason: 'RET' };
  return someFinalComputation();
}
```

---

## 10.4 조건부 로직을 다형성으로 바꾸기 (Replace Conditional with Polymorphism)

**배경**
- 같은 타입 코드로 분기하는 switch/if가 여러 곳에 반복되면(반복되는 switch 3.12), 타입별 클래스(서브클래스)를 만들고 각 분기를 **오버라이드 메서드**로 옮긴다.
- 또 하나의 유형: 기본 동작은 슈퍼클래스에, **변형 동작(variation)** 만 서브클래스에 두는 경우.
- 모든 조건문을 다형성으로 바꿀 필요는 없다. 단순 조건문은 그대로 두라. 조건부 로직이 **복잡하고 반복될 때** 쓴다.

**절차**
1. 다형적 동작을 표현하는 클래스들이 아직 없다면 만든다. 인스턴스를 알맞게 만들어 반환하는 **팩터리 함수**도 함께.
2. 호출 코드에서 팩터리 함수를 사용하게 한다.
3. 조건부 로직 함수를 슈퍼클래스로 옮긴다(8.1). (조건부 로직이 온전한 함수가 아니면 먼저 추출 6.1.)
4. 서브클래스 중 하나를 선택해 슈퍼클래스의 조건부 로직 메서드를 오버라이드한다. 조건문에서 해당 서브클래스 분기 코드를 복사해 넣고 다듬는다.
5. 같은 방식으로 각 조건절을 해당 서브클래스로 옮긴다.
6. 슈퍼클래스 메서드에는 기본 동작만 남긴다. 슈퍼클래스가 추상이거나 기본 동작이 없으면 메서드를 추상으로 선언하거나 에러를 던지게 한다.

**예시**
```js
// before
function plumage(bird) {
  switch (bird.type) {
    case '유럽 제비': return '보통';
    case '아프리카 제비': return bird.numberOfCoconuts > 2 ? '지침' : '보통';
    case '노르웨이 파랑 앵무': return bird.voltage > 100 ? '그을림' : '예쁨';
    default: return '알 수 없음';
  }
}
// after
class Bird { get plumage() { return '알 수 없음'; } }
class EuropeanSwallow extends Bird { get plumage() { return '보통'; } }
class AfricanSwallow extends Bird { get plumage() { return this.numberOfCoconuts > 2 ? '지침' : '보통'; } }
class NorwegianBlueParrot extends Bird { get plumage() { return this.voltage > 100 ? '그을림' : '예쁨'; } }
function createBird(bird) { /* type에 따라 서브클래스 인스턴스 반환 */ }
```

---

## 10.5 특이 케이스 추가하기 (Introduce Special Case)
- 1판 이름: 널 객체 추가(Introduce Null Object)

**배경**
- 특정 값(주로 `null`, 또는 "미확인 고객" 같은 특별한 값)을 확인하는 코드가 **여러 곳에 반복**되면, 그 특이 케이스를 표현하는 **객체**를 만들어 공통 동작을 담는다. 조건문 대부분이 사라진다.
- 특이 케이스 객체는 클래스일 수도, 불변 리터럴 객체일 수도 있다. 클라이언트가 특이 케이스를 다르게 처리해야 하면 `isUnknown` 같은 질의를 둔다.

**절차**
1. 컨테이너(특이 케이스 대상 속성을 담은 클래스)에 특이 케이스인지 검사하는 속성(`isUnknown`)을 추가하고 `false`를 반환하게 한다.
2. 특이 케이스 객체(클래스)를 만든다. 이 객체는 특이 케이스 검사 속성만 갖고 `true`를 반환한다.
3. 클라이언트에서 특이 케이스 검사 코드를 함수로 추출(6.1)한다. 모든 클라이언트가 이 함수를 쓰게.
4. 코드에 새로운 특이 케이스 대상을 추가한다(함수 반환값이나 변환 함수 적용).
5. 특이 케이스 검사 함수 본문을 수정하여 특이 케이스 객체의 속성을 사용하도록 한다.
6. 테스트.
7. 여러 함수를 클래스로 묶기(6.9) 또는 변환 함수로 묶기(6.10)로 특이 케이스 공통 동작을 새 요소로 옮긴다.
8. 특이 케이스 검사 함수를 아직 이용하는 곳이 있다면 검사 함수를 인라인(6.2)한다.

**예시**
```js
// before
const customer = site.customer;
let customerName;
if (customer === '미확인 고객') customerName = '거주자';
else customerName = customer.name;
// after
class UnknownCustomer {
  get isUnknown() { return true; }
  get name() { return '거주자'; }
}
class Site { get customer() { return this._customer === '미확인 고객' ? new UnknownCustomer() : this._customer; } }
const customerName = site.customer.name;
```

---

## 10.6 어서션 추가하기 (Introduce Assertion)

**배경**
- 특정 조건이 참일 때만 제대로 동작하는 코드가 있다. 그 **가정을 어서션으로 명시**하면 코드를 읽는 사람에게 설명이 되고, 디버깅에도 도움이 된다.
- 어서션은 **항상 참이어야 하는 것**만. 어서션 실패는 프로그래머의 오류다. 사용자 입력 검증에는 쓰지 않는다.
- 어서션이 없어도 프로그램은 동작해야 한다(어서션은 언제든 제거될 수 있다). 남용하지 마라 — "반드시 참"이라고 믿는 것만 검사한다.

**절차**
1. 참이라고 가정하는 조건이 보이면 그 조건을 명시하는 어서션을 추가한다.
- 어서션은 시스템 동작에 영향을 주지 않으므로 추가 자체가 동작을 바꾸지 않는다.

**예시**
```js
// before
if (this.discountRate) base = base - this.discountRate * base;
// after
assert(this.discountRate >= 0);
if (this.discountRate) base = base - this.discountRate * base;
```

---

## 10.7 제어 플래그를 탈출문으로 바꾸기 (Replace Control Flag with Break)
- 1판 이름: 제어 플래그 제거(Remove Control Flag)

**배경**
- `done = true` 같은 플래그 변수로 반복문·조건문을 빠져나가는 코드는 `break`, `continue`, `return`으로 바꾸는 편이 명확하다.
- 제어 플래그는 보통 반복문 안에 있으며, 함수를 추출(6.1)해 `return`으로 대체하는 것이 가장 깔끔하다.

**절차**
1. 제어 플래그를 사용하는 코드를 함수로 추출(6.1)할지 고려.
2. 제어 플래그를 갱신하는 코드 각각을 적절한 제어문(`break`/`continue`/`return`)으로 바꾼다. 매번 테스트.
3. 모두 바꿨다면 제어 플래그를 제거한다.

**예시**
```js
// before
let found = false;
for (const p of people) {
  if (!found) {
    if (p === '조커') { sendAlert(); found = true; }
  }
}
// after
for (const p of people) {
  if (p === '조커') { sendAlert(); break; }
}
// 또는 함수로 추출하고 return
```
