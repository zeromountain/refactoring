# 11장 API 리팩터링 (Refactoring APIs)

모듈 사이의 이음매인 API를 이해하기 쉽고 쓰기 쉽게 만든다. 질의와 변경을 분리하고, 매개변수를 다듬고, 불변성을 높인다.

---

## 11.1 질의 함수와 변경 함수 분리하기 (Separate Query from Modifier)

**배경**
- 값을 반환하면서 부작용도 있는 함수는 위험하다. **질의(query)** 는 부작용이 없어야 한다 — 그래야 어디서든, 몇 번이든 안심하고 호출하고 테스트도 쉽다.
- **명령-질의 분리(CQS)**: 값을 반환하는 함수는 부작용이 없어야 한다. 캐싱처럼 겉보기 동작에 영향 없는 내부 상태 변경은 예외.

**절차**
1. 대상 함수를 복제하고 질의 목적에 맞는 이름을 짓는다(함수가 "무엇을 반환하는지"로).
2. 새 질의 함수에서 부작용을 모두 제거한다.
3. 정적 검사.
4. 원래 함수를 호출하는 곳을 모두 찾아, 반환값을 사용한다면 질의 함수를 호출하도록 바꾸고 원래 함수 호출을 바로 아래에 추가한다. 매번 테스트.
5. 원래 함수에서 질의 관련 코드를 제거한다(반환값 없앰).
6. 테스트.
- 이후 질의 함수와 변경 함수에 중복이 있으면 알고리즘 교체(7.9) 등으로 정리.

**예시**
```js
// before
function alertForMiscreant(people) {
  for (const p of people) {
    if (p === '조커') { setOffAlarms(); return '조커'; }
  }
  return '';
}
// after
function findMiscreant(people) { return people.find(p => p === '조커') || ''; }
function alertForMiscreant(people) { if (findMiscreant(people) !== '') setOffAlarms(); }
```

---

## 11.2 함수 매개변수화하기 (Parameterize Function)
- 1판 이름: 메서드 매개변수화(Parameterize Method)

**배경**
- 두 함수의 로직이 거의 같고 **리터럴 값만 다르다면** 그 값을 매개변수로 받는 함수 하나로 합친다.
- 여러 비슷한 함수 중 **중간에 있는 것**(범위 계산 등에서 가장 일반적인 경우)을 골라 시작하면 편하다.

**절차**
1. 비슷한 함수 중 하나를 선택한다.
2. 함수 선언 바꾸기(6.5)로 리터럴들을 매개변수로 추가한다.
3. 이 함수를 호출하는 곳 모두에 적절한 리터럴 값을 추가한다.
4. 테스트.
5. 매개변수로 받은 값을 사용하도록 함수 본문을 수정한다. 매번 테스트.
6. 비슷한 다른 함수를 호출하는 코드를 찾아 매개변수화된 함수를 호출하도록 하나씩 수정한다. 매번 테스트.

**예시**
```js
// before
function tenPercentRaise(p) { p.salary = p.salary.multiply(1.1); }
function fivePercentRaise(p) { p.salary = p.salary.multiply(1.05); }
// after
function raise(p, factor) { p.salary = p.salary.multiply(1 + factor); }
```

---

## 11.3 플래그 인수 제거하기 (Remove Flag Argument)
- 1판 이름: 매개변수를 명시적 함수들로 바꾸기(Replace Parameter with Explicit Methods)

**배경**
- **플래그 인수**: 호출자가 함수의 동작 분기를 선택하기 위해 넘기는 불리언·열거값 등(`bookConcert(customer, true)`). 호출문만 봐서는 의미를 알 수 없고, 함수 안에 조건문이 생긴다.
- 대신 분기별로 **명시적인 함수**를 제공한다(`premiumBookConcert(customer)`).
- 플래그가 여러 개라면 조합이 폭발하므로 이 기법 대신 함수 자체를 쪼개야 한다는 신호. 호출자가 리터럴로 넘기는 경우만 플래그 인수다(변수에 담긴 값을 넘기면 데이터 인수).

**절차**
1. 매개변수로 주어질 수 있는 값 각각에 대응하는 **명시적 함수**를 생성한다(조건문 분해 10.1 후 각 분기를 새 함수로, 또는 원래 함수를 래핑).
2. 원래 함수를 호출하는 코드들을 모두 찾아, 각 리터럴 값에 대응되는 명시적 함수를 호출하도록 수정한다.

**예시**
```js
// before
function deliveryDate(anOrder, isRush) { if (isRush) {/*...*/} else {/*...*/} }
deliveryDate(order, true);
// after
function rushDeliveryDate(anOrder) { /*...*/ }
function regularDeliveryDate(anOrder) { /*...*/ }
rushDeliveryDate(order);
```

---

## 11.4 객체 통째로 넘기기 (Preserve Whole Object)

**배경**
- 레코드에서 값 둘 이상을 꺼내 인수로 넘기면, 레코드 자체를 넘기게 한다. 매개변수 목록이 짧아지고, 나중에 더 많은 데이터가 필요할 때 시그니처를 바꿀 필요가 없다.
- 단, 함수가 레코드 **전체에 의존**하게 되어 결합도가 오른다. 함수와 레코드가 다른 모듈에 있다면 다시 생각한다.
- 한 객체가 자신의 속성 여러 개를 꺼내 넘긴다면 `this`를 넘기면 된다 — 함수가 그 객체로 옮겨 가야 한다는 신호(8.1)일 수도 있다.

**절차**
1. 매개변수들을 원하는 형태로 받는 **빈 함수**를 만든다(임시 이름).
2. 새 함수 본문에서는 원래 함수를 호출하며, 새 매개변수(객체)와 원래 매개변수를 매핑한다.
3. 정적 검사.
4. 원래 함수를 호출하는 곳을 모두 새 함수 호출로 바꾼다. 매번 테스트.
5. 모두 바꿨으면 원래 함수를 새 함수 안으로 인라인(6.2)한다.
6. 새 함수 이름을 원래 이름으로 바꾸고(6.5) 호출자를 수정한다.

**예시**
```js
// before
const low = aRoom.daysTempRange.low, high = aRoom.daysTempRange.high;
if (aPlan.withinRange(low, high)) {}
// after
if (aPlan.withinRange(aRoom.daysTempRange)) {}
```

---

## 11.5 매개변수를 질의 함수로 바꾸기 (Replace Parameter with Query)
- 1판 이름: 매개변수를 메서드로 바꾸기(Replace Parameter with Method) · 반대: 질의 함수를 매개변수로 바꾸기(11.6)

**배경**
- 호출자가 넘기는 값을 **함수 스스로 쉽게 구할 수 있다면**(다른 매개변수로부터, 또는 `this`의 상태로부터) 매개변수를 제거한다. 매개변수 목록이 짧을수록 호출자가 편하다.
- 대상 함수가 참조 투명성(같은 입력 → 같은 출력)을 잃게 되면 하지 않는다. 즉, 제거하려는 매개변수의 값을 구하는 로직이 **부작용 없고 결정적**일 때만.

**절차**
1. 필요하다면 대상 매개변수의 값을 계산하는 코드를 별도 함수로 추출(6.1)한다.
2. 함수 본문에서 대상 매개변수를 참조하는 곳을 모두 새 함수 호출로 바꾼다. 매번 테스트.
3. 함수 선언 바꾸기(6.5)로 대상 매개변수를 없앤다.

**예시**
```js
// before
availableVacation(anEmployee, anEmployee.grade);
function availableVacation(anEmployee, grade) {}
// after
availableVacation(anEmployee);
function availableVacation(anEmployee) { const grade = anEmployee.grade; }
```

---

## 11.6 질의 함수를 매개변수로 바꾸기 (Replace Query with Parameter)
- 반대: 매개변수를 질의 함수로 바꾸기(11.5)

**배경**
- 함수 안에서 전역 변수나 특정 객체를 직접 참조하는 부분이 **불편한 의존성**이면, 그 값을 매개변수로 받게 한다. 함수가 참조 투명해지고 테스트하기 쉬워진다.
- 대가: 호출자가 값을 구해 넘겨야 하므로 호출자가 복잡해진다. 모듈 경계 설계의 문제이며 정답은 없다.

**절차**
1. 변수 추출(6.3)로 질의 코드를 함수 본문의 나머지와 분리한다.
2. 함수 본문 중 질의를 실행하지 않는 부분을 별도 함수로 추출(6.1)한다.
3. 방금 만든 변수를 인라인(6.4)해 제거한다.
4. 원래 함수도 인라인(6.2)한다.
5. 새 함수 이름을 원래 함수 이름으로 바꾼다(6.5).

**예시**
```js
// before
targetTemperature(aPlan);
function targetTemperature(aPlan) { const currentTemperature = thermostat.currentTemperature; /* ... */ }
// after
targetTemperature(aPlan, thermostat.currentTemperature);
function targetTemperature(aPlan, currentTemperature) { /* ... */ }
```

---

## 11.7 세터 제거하기 (Remove Setting Method)

**배경**
- 세터가 있다는 것은 필드가 수정될 수 있다는 뜻. 생성 후 바뀌면 안 되는 필드라면 세터를 제거해 **불변**을 보장하고 의도를 드러낸다.
- 흔한 사례: 생성자에서만 세터를 쓰는 경우, 클라이언트가 생성 스크립트(생성 후 일련의 세터 호출)로 객체를 만드는 경우.

**절차**
1. 설정해야 할 값을 생성자에서 받지 않는다면 그 값을 받을 매개변수를 생성자에 추가한다(6.5). 생성자 안에서 세터를 호출한다.
2. 생성자 밖에서 세터를 호출하는 곳을 찾아 제거하고, 대신 새로운 생성자를 사용하도록 한다. 매번 테스트.
3. 세터 메서드를 인라인(6.2)한다. 가능하다면 해당 필드를 불변으로 만든다.
4. 테스트.

**예시**
```js
// before
class Person { get name() {} set name(v) {} }
const p = new Person(); p.name = '마틴';
// after
class Person { constructor(name) { this._name = name; } get name() {} }
const p = new Person('마틴');
```

---

## 11.8 생성자를 팩터리 함수로 바꾸기 (Replace Constructor with Factory Function)
- 1판 이름: 생성자를 팩터리 메서드로 바꾸기(Replace Constructor with Factory Method)

**배경**
- 생성자는 제약이 많다: 반드시 해당 클래스 인스턴스를 반환해야 하고(서브클래스나 프락시 불가), 이름이 고정되며(`new`), 일급 함수처럼 넘길 수 없다.
- 팩터리 함수는 이런 제약이 없다. 특히 타입 코드로 서브클래스를 고르는 경우(12.6)에 필요하다.

**절차**
1. 팩터리 함수를 만든다. 팩터리 함수의 본문에서는 원래의 생성자를 호출한다.
2. 생성자를 호출하던 코드를 팩터리 함수 호출로 바꾼다. 매번 테스트.
3. 생성자의 가시 범위가 최소가 되도록 제한한다.

**예시**
```js
// before
leadEngineer = new Employee(document.leadEngineer, 'E');
// after
leadEngineer = createEngineer(document.leadEngineer);
function createEngineer(name) { return new Employee(name, 'E'); }
```

---

## 11.9 함수를 명령으로 바꾸기 (Replace Function with Command)
- 1판 이름: 메서드를 메서드 객체로 바꾸기(Replace Method with Method Object) · 반대: 명령을 함수로 바꾸기(11.10)

**배경**
- 함수를 그 함수만을 위한 객체(**명령 객체**, command)로 감싸면 되돌리기(undo), 생명주기 관리, 상속·훅을 통한 커스터마이즈, 일급 함수가 없는 언어에서의 함수 전달 등이 가능해진다.
- 가장 큰 쓸모: **매우 복잡한 함수를 잘게 쪼갤 때**. 지역 변수를 필드로 옮기면 함수 추출(6.1)이 쉬워진다(긴 함수 3.3의 최후 수단).
- 일급 함수를 지원하는 언어라면 대부분 그냥 함수로 충분하다. 유연성이 실제로 필요할 때만 쓴다.

**절차**
1. 대상 함수의 기능을 옮길 빈 클래스를 만든다. 클래스 이름은 함수 이름에 기초해 짓는다.
2. 방금 생성한 빈 클래스로 함수를 옮긴다(8.1). 실행 메서드 이름은 `execute`, `call` 등.
3. 함수의 인수들 각각은 명령의 필드로 만들어 생성자를 통해 설정할지 고려한다.
4. 이후 본문에서 지역 변수를 필드로 바꾸고, 함수 추출(6.1)로 잘게 나눈다.

**예시**
```js
// before
function score(candidate, medicalExam, scoringGuide) { let result = 0; let healthLevel = 0; /* 긴 로직 */ }
// after
class Scorer {
  constructor(candidate, medicalExam, scoringGuide) { /* 필드에 저장 */ }
  execute() { this._result = 0; this._healthLevel = 0; this.scoreSmoking(); /* ... */ return this._result; }
  scoreSmoking() { /* 추출된 조각 */ }
}
function score(candidate, medicalExam, scoringGuide) { return new Scorer(candidate, medicalExam, scoringGuide).execute(); }
```

---

## 11.10 명령을 함수로 바꾸기 (Replace Command with Function)
- 반대: 함수를 명령으로 바꾸기(11.9)

**배경**
- 명령 객체의 유연성이 필요 없고, 로직이 그리 복잡하지 않다면 평범한 함수로 되돌린다.

**절차**
1. 명령을 생성하는 코드와 명령의 실행 메서드를 호출하는 코드를 함께 함수로 추출(6.1)한다.
2. 명령의 실행 메서드가 호출하는 보조 메서드들 각각을 인라인(6.2)한다.
3. 함수 선언 바꾸기(6.5)를 적용하여 생성자의 매개변수 모두를 실행 메서드로 옮긴다.
4. 실행 메서드에서 참조하는 필드들 대신 대응하는 매개변수를 사용하게 바꾼다. 매번 테스트.
5. 생성자 호출과 실행 메서드 호출을 호출자 안으로 인라인(6.2)한다.
6. 테스트.
7. 죽은 코드 제거(8.9)로 명령 클래스를 없앤다.

**예시**
```js
// before
class ChargeCalculator {
  constructor(customer, usage) { this._customer = customer; this._usage = usage; }
  execute() { return this._customer.rate * this._usage; }
}
monthCharge = new ChargeCalculator(customer, usage).execute();
// after
function charge(customer, usage) { return customer.rate * usage; }
monthCharge = charge(customer, usage);
```

---

## 11.11 수정된 값 반환하기 (Return Modified Value)

**배경**
- 함수가 값을 **수정**하는지 호출자가 알기 어렵다. 수정된 값을 **반환**하게 하면 "이 함수가 이 값을 바꾼다"는 것이 호출문에 드러난다(`totalAscent = calculateAscent()`).
- 값 하나를 계산·갱신하는 함수에 적합. 여러 값을 갱신하는 함수에는 적합하지 않다.
- 함수 옮기기(8.1)의 준비 단계로도 유용.

**절차**
1. 함수가 수정된 값을 반환하게 한다.
2. 호출자가 그 반환값을 자신의 변수에 저장하게 한다.
3. 테스트.
4. 피호출 함수 안에 반환할 값을 가리키는 새로운 변수를 선언한다.
5. 테스트.
6. 계산이 선언과 동시에 이뤄지도록 통합한다(즉, 선언 시점에 계산 로직을 바로 실행해 대입한다).
7. 테스트.
8. 피호출 함수의 변수 이름을 새 역할에 어울리도록 바꿔 준다.
9. 테스트.

**예시**
```js
// before
let totalAscent = 0;
calculateAscent();
function calculateAscent() { for (let i = 1; i < points.length; i++) { const d = points[i].elevation - points[i-1].elevation; totalAscent += d > 0 ? d : 0; } }
// after
const totalAscent = calculateAscent();
function calculateAscent() { let result = 0; for (/* ... */) { result += d > 0 ? d : 0; } return result; }
```

---

## 11.12 오류 코드를 예외로 바꾸기 (Replace Error Code with Exception)

**배경**
- 오류 코드는 호출자가 매번 검사하고 위로 전달해야 한다. 예외는 오류 처리 로직을 정상 흐름과 분리하고, 적절한 처리기까지 자동으로 전파된다.
- 예외는 **정확히 예상 밖의 오류**에만 쓴다. 호출자가 사전에 검사해 회피할 수 있는 상황(예상 가능한 조건)에는 오류 코드나 사전 확인이 낫다(11.13). "예외를 던지는 코드를 제거해도 프로그램이 정상 동작하는가?"가 시험.

**절차**
1. 콜스택 상위에 해당 예외를 처리할 예외 핸들러를 작성한다(처음엔 단순히 다시 던진다).
2. 테스트.
3. 해당 오류 코드를 대체할 예외와 그 밖의 예외를 구분할 식별 방법을 찾는다(예외 클래스 또는 속성).
4. 정적 검사.
5. catch절을 수정하여 직접 처리할 수 있는 예외는 적절히 대처하고 그렇지 않은 예외는 다시 던지게 한다.
6. 테스트.
7. 오류 코드를 반환하는 곳 모두에서 예외를 던지도록 수정한다. 매번 테스트.
8. 모두 수정했다면 오류 코드를 콜스택 위로 전달하는 코드를 모두 제거한다. 매번 테스트.

**예시**
```js
// before
if (data) return new ShippingRules(data);
else return -23;
// after
if (data) return new ShippingRules(data);
else throw new OrderProcessingError(-23);
```

---

## 11.13 예외를 사전확인으로 바꾸기 (Replace Exception with Precheck)
- 1판 이름: 예외를 테스트로 바꾸기(Replace Exception with Test)

**배경**
- 호출하기 전에 **조건을 미리 검사**할 수 있는 상황이라면, 예외를 던지는 대신 조건을 검사한다. 예외는 예상 밖의 오류를 위한 것이지 제어 흐름 수단이 아니다.

**절차**
1. 예외를 유발하는 상황을 검사할 수 있는 조건문을 추가한다. catch 블록의 코드를 조건문의 조건절 중 하나로 옮기고, 남은 try 블록의 코드를 다른 조건절로 옮긴다.
2. catch 블록에 어서션(10.6)을 추가하고 테스트.
3. try문과 catch 블록을 제거한다.
4. 테스트.

**예시**
```java
// before
double getValueForPeriod(int periodNumber) {
  try { return values[periodNumber]; }
  catch (ArrayIndexOutOfBoundsException e) { return 0; }
}
// after
double getValueForPeriod(int periodNumber) {
  return (periodNumber >= values.length) ? 0 : values[periodNumber];
}
```
