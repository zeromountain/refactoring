# 12장 상속 다루기 (Dealing with Inheritance)

상속은 강력하지만 오용되기 쉽다. 계층 위아래로 요소를 옮기고, 계층을 만들거나 없애고, 상속을 위임으로 바꾼다.

---

## 12.1 메서드 올리기 (Pull Up Method)
- 반대: 메서드 내리기(12.4)

**배경**
- 서브클래스 여럿에 **똑같은(또는 거의 같은) 메서드**가 있으면 슈퍼클래스로 올린다. 중복 코드(3.2)는 한쪽만 고치기 쉬워 위험하다.
- 본문이 같은 필드를 참조하면 필드 올리기(12.2) 먼저. 메서드 절차는 같은데 세부만 다르면 **템플릿 메서드** 패턴(공통 부분 올리고 다른 부분은 서브클래스 메서드로) 고려. 슈퍼클래스가 서브클래스 메서드를 호출해야 한다면 그 메서드를 추상으로 올린다.

**절차**
1. 똑같이 동작하는 메서드인지 면밀히 살펴본다(형식이 다르면 함수 선언 바꾸기 6.5로 맞추고 리팩터링해 같은 형태로).
2. 메서드 안에서 호출하는 다른 메서드와 참조하는 필드들을 슈퍼클래스에서도 호출·참조할 수 있는지 확인한다.
3. 슈퍼클래스에 새로운 메서드를 생성하고, 대상 메서드의 코드를 복사해 넣는다.
4. 정적 검사.
5. 서브클래스 중 하나의 메서드를 제거한다.
6. 테스트.
7. 모든 서브클래스의 메서드가 없어질 때까지 다른 서브클래스의 메서드를 하나씩 제거한다.

**예시**
```js
// before
class Employee extends Party { get annualCost() { return this.monthlyCost * 12; } }
class Department extends Party { get totalAnnualCost() { return this.monthlyCost * 12; } }
// after
class Party { get annualCost() { return this.monthlyCost * 12; } }
```

---

## 12.2 필드 올리기 (Pull Up Field)
- 반대: 필드 내리기(12.5)

**배경**
- 서브클래스들이 독립적으로 개발되면 같은 역할의 필드가 각각 생긴다(이름은 다를 수 있음). 슈퍼클래스로 올리면 중복이 사라지고, 그 필드를 쓰는 메서드도 올릴 수 있다(12.1).

**절차**
1. 후보 필드들을 사용하는 곳을 모두 살펴서 그것들이 똑같은 방식으로 이용되는지 확인한다.
2. 필드들의 이름이 각기 다르다면 똑같은 이름으로 바꾼다(9.2).
3. 슈퍼클래스에 새로운 필드를 생성한다(서브클래스에서 접근 가능하게).
4. 서브클래스의 필드들을 제거한다.
5. 테스트.

**예시**
```js
// before
class Employee {}
class Salesperson extends Employee { name; }
class Engineer extends Employee { name; }
// after
class Employee { name; }
```

---

## 12.3 생성자 본문 올리기 (Pull Up Constructor Body)

**배경**
- 서브클래스 생성자들에 공통 코드가 있으면 슈퍼클래스 생성자로 올린다. 생성자는 호출 순서 제약(`super()` 먼저)이 있어 메서드 올리기(12.1)와 절차가 다르다.
- 공통 코드가 `super()` 이후에 와야 하고 리팩터링이 복잡해지면, 생성자를 팩터리 함수로 바꾸기(11.8)가 낫다.

**절차**
1. 슈퍼클래스에 생성자가 없다면 하나 정의한다. 서브클래스의 생성자들에서 이 생성자가 호출되는지 확인한다.
2. 문장 슬라이드(8.6)로 공통 문장 모두를 `super()` 호출 직후로 옮긴다.
3. 공통 코드를 슈퍼클래스 생성자로 옮기고, 서브클래스 생성자에서는 `super()` 호출 인수로 전달한다.
4. 테스트.
5. 생성자 시작 부분으로 옮길 수 없는 공통 코드에는 함수 추출(6.1)과 메서드 올리기(12.1)를 차례로 적용한다.

**예시**
```js
// before
class Party {}
class Employee extends Party {
  constructor(name, id, monthlyCost) { super(); this._id = id; this._name = name; this._monthlyCost = monthlyCost; }
}
// after
class Party { constructor(name) { this._name = name; } }
class Employee extends Party {
  constructor(name, id, monthlyCost) { super(name); this._id = id; this._monthlyCost = monthlyCost; }
}
```

---

## 12.4 메서드 내리기 (Push Down Method)
- 반대: 메서드 올리기(12.1)

**배경**
- 특정 서브클래스 하나(또는 소수)에만 관련된 메서드는 슈퍼클래스에서 제거하고 해당 서브클래스로 옮긴다.
- 호출자가 해당 기능을 제공하는 서브클래스를 **정확히 알고** 있을 때만. 그렇지 않으면 조건부 로직을 다형성으로 바꾸기(10.4)가 맞다.

**절차**
1. 대상 메서드를 모든 서브클래스에 복사한다.
2. 슈퍼클래스에서 그 메서드를 제거한다.
3. 테스트.
4. 이 메서드를 사용하지 않는 모든 서브클래스에서 제거한다.
5. 테스트.

**예시**
```js
// before
class Employee { get quota() {} }
class Engineer extends Employee {}
class Salesperson extends Employee {}
// after
class Employee {}
class Engineer extends Employee {}
class Salesperson extends Employee { get quota() {} }
```

---

## 12.5 필드 내리기 (Push Down Field)
- 반대: 필드 올리기(12.2)

**배경**
- 서브클래스 하나(또는 소수)에서만 사용하는 필드는 해당 서브클래스로 옮긴다.

**절차**
1. 대상 필드를 모든 서브클래스에 정의한다.
2. 슈퍼클래스에서 그 필드를 제거한다.
3. 테스트.
4. 이 필드를 사용하지 않는 모든 서브클래스에서 제거한다.
5. 테스트.

**예시**
```java
// before
class Employee { private String quota; }
class Engineer extends Employee {}
class Salesperson extends Employee {}
// after
class Employee {}
class Engineer extends Employee {}
class Salesperson extends Employee { protected String quota; }
```

---

## 12.6 타입 코드를 서브클래스로 바꾸기 (Replace Type Code with Subclasses)
- 1판 이름: 서브클래스 추출(Extract Subclass), 타입 코드를 상태/전략 패턴으로 바꾸기(Replace Type Code with State/Strategy) · 반대: 서브클래스 제거하기(12.7)

**배경**
- 타입 코드(문자열·열거값)로 비슷한 것들을 구분하고 있다. 타입 코드만으로 충분할 때도 많지만, 다음 상황이면 서브클래스를 만든다:
  1. 타입 코드에 따라 **다르게 동작**하는 조건부 로직이 있다 → 조건부 로직을 다형성으로(10.4)의 발판.
  2. 특정 타입에서만 의미 있는 필드·메서드가 있다 → 해당 서브클래스로 내린다(12.4, 12.5).
- 두 가지 방식: **직접 상속**(`Engineer extends Employee`) 또는 **간접 상속**(타입 코드 자체를 객체로 만들어 `EmployeeType` 계층을 두고 `Employee`가 소유). 이미 다른 이유로 서브클래스가 있거나 타입이 바뀔 수 있으면 간접 상속.
- 팩터리 함수(11.8)가 필수 — 생성자는 서브클래스를 고를 수 없다.

**절차**
1. 타입 코드 필드를 자가 캡슐화(6.6)한다.
2. 타입 코드 값 하나를 선택하여 그 값에 해당하는 서브클래스를 만든다. 타입 코드 게터 메서드를 오버라이드하여 해당 타입 코드의 리터럴 값을 반환하게 한다.
3. 매개변수로 받은 타입 코드와 방금 만든 서브클래스를 매핑하는 선택 로직을 만든다(직접 상속: 생성자를 팩터리 함수로 바꾸기 11.8 후 팩터리에서 선택 / 간접 상속: 생성자에서 타입 코드 객체 생성 로직으로).
4. 테스트.
5. 타입 코드 값 각각에 대해 서브클래스 생성과 선택 로직 추가를 반복한다. 매번 테스트.
6. 타입 코드 필드를 제거한다.
7. 테스트.
8. 타입 코드 접근자를 이용하는 메서드 모두에 메서드 내리기(12.4)와 조건부 로직을 다형성으로 바꾸기(10.4)를 적용한다.

**예시**
```js
// before
function createEmployee(name, type) { return new Employee(name, type); }
// after (직접 상속)
class Engineer extends Employee { get type() { return 'engineer'; } }
class Salesperson extends Employee { get type() { return 'salesperson'; } }
function createEmployee(name, type) {
  switch (type) {
    case 'engineer': return new Engineer(name);
    case 'salesperson': return new Salesperson(name);
  }
}
```

---

## 12.7 서브클래스 제거하기 (Remove Subclass)
- 1판 이름: 서브클래스를 필드로 바꾸기(Replace Subclass with Fields) · 반대: 타입 코드를 서브클래스로 바꾸기(12.6)

**배경**
- 서브클래스가 너무 적은 일을 해서 존재 가치가 없으면(성의 없는 요소 3.14) 슈퍼클래스의 **필드**로 대체한다. 서브클래스는 이해에 비용을 요구한다.

**절차**
1. 서브클래스의 생성자를 팩터리 함수로 바꾼다(11.8).
2. 서브클래스의 타입을 검사하는 코드가 있다면 그 검사 코드에 함수 추출(6.1)과 함수 옮기기(8.1)를 차례로 적용하여 슈퍼클래스로 옮긴다. 매번 테스트.
3. 서브클래스의 타입을 나타내는 필드를 슈퍼클래스에 만든다.
4. 서브클래스를 참조하는 메서드가 방금 만든 타입 필드를 이용하도록 수정한다.
5. 서브클래스를 지운다.
6. 테스트.

**예시**
```js
// before
class Person { get genderCode() { return 'X'; } }
class Male extends Person { get genderCode() { return 'M'; } }
class Female extends Person { get genderCode() { return 'F'; } }
// after
class Person {
  constructor(name, genderCode) { this._genderCode = genderCode || 'X'; }
  get genderCode() { return this._genderCode; }
}
```

---

## 12.8 슈퍼클래스 추출하기 (Extract Superclass)

**배경**
- 비슷한 일을 하는 두 클래스가 보이면 공통 부분을 슈퍼클래스로 옮긴다(12.1, 12.2). 상속은 처음부터 설계할 필요 없이 **나중에 발견해도** 된다.
- 대안은 클래스 추출(7.5, 위임). 슈퍼클래스 추출이 더 간단해서 보통 이것부터 하고, 나중에 필요하면 슈퍼클래스를 위임으로 바꾼다(12.11).

**절차**
1. 빈 슈퍼클래스를 만든다. 원래의 클래스들이 새 클래스를 상속하도록 한다.
2. 테스트.
3. 생성자 본문 올리기(12.3), 메서드 올리기(12.1), 필드 올리기(12.2)를 차례로 적용하여 공통 원소를 모두 슈퍼클래스로 옮긴다.
4. 서브클래스에 남은 메서드들을 검토한다. 공통되는 부분이 있다면 함수로 추출(6.1)한 다음 메서드 올리기(12.1)를 적용한다.
5. 원래 클래스들을 사용하는 코드를 검토하여 슈퍼클래스의 인터페이스를 사용하게 할지 고민해 본다.

**예시**
```js
// before
class Department { get totalAnnualCost() {} get name() {} get headCount() {} }
class Employee { get annualCost() {} get name() {} get id() {} }
// after
class Party { get name() {} get annualCost() {} }
class Department extends Party { get headCount() {} }
class Employee extends Party { get id() {} }
```

---

## 12.9 계층 합치기 (Collapse Hierarchy)

**배경**
- 계층을 리팩터링하다 보면 슈퍼클래스와 서브클래스가 너무 비슷해져 독립적으로 존재할 이유가 없어진다. 그러면 하나로 합친다.

**절차**
1. 두 클래스 중 제거할 것을 고른다(더 적합한 이름이 남도록).
2. 필드 올리기(12.2)와 메서드 올리기(12.1) 혹은 필드 내리기(12.5)와 메서드 내리기(12.4)를 적용하여 모든 요소를 하나의 클래스로 모은다.
3. 제거할 클래스를 참조하던 코드가 남겨질 클래스를 참조하도록 고친다.
4. 빈 클래스를 제거한다.
5. 테스트.

**예시**
```js
// before
class Employee {}
class Salesperson extends Employee {}
// after
class Employee {}
```

---

## 12.10 서브클래스를 위임으로 바꾸기 (Replace Subclass with Delegate)

**배경**
- 상속의 단점: (1) 한 번에 **한 축**으로만 분류할 수 있다(사람을 나이로도, 소득으로도 나누고 싶으면 상속으론 불가). (2) 클래스 간 관계가 **매우 강하게 결합**된다 — 부모 수정이 자식을 쉽게 깨뜨린다.
- 위임(delegation)은 두 문제를 모두 해결한다. "상속보다 컴포지션(위임)을 우선하라"는 GoF의 원칙. 다만 상속이 잘 맞는 경우도 많으니 **처음엔 상속으로 시작하고 문제가 생기면 위임으로 바꾼다.**
- 위임 객체는 상태(state) 패턴이나 전략(strategy) 패턴의 형태가 된다.

**절차**
1. 생성자를 호출하는 곳이 많다면 생성자를 팩터리 함수로 바꾼다(11.8).
2. 위임으로 활용할 빈 클래스를 만든다. 이 클래스의 생성자는 서브클래스에 특화된 데이터를 전부 받아야 하며, 보통은 슈퍼클래스를 가리키는 역참조도 필요하다.
3. 위임을 저장할 필드를 슈퍼클래스에 추가한다.
4. 서브클래스 생성 코드를 수정하여 위임 인스턴스를 생성하고 위임 필드에 대입해 초기화한다(팩터리 함수 또는 생성자에서).
5. 서브클래스의 메서드 중 위임 클래스로 이동할 것을 고른다.
6. 함수 옮기기(8.1)를 적용해 위임 클래스로 옮긴다. 원래 메서드에서 위임하는 코드는 지우지 않는다.
7. 서브클래스 외부에도 원래 메서드를 호출하는 코드가 있다면 서브클래스의 위임 코드를 슈퍼클래스로 옮긴다. 이때 위임이 존재하는지 검사하는 보호 코드로 감싼다. 호출하는 외부 코드가 없다면 원래 메서드는 죽은 코드가 되므로 제거(8.9)한다.
8. 테스트.
9. 서브클래스의 모든 메서드가 옮겨질 때까지 5~8 과정을 반복한다.
10. 서브클래스들의 생성자를 호출하는 코드를 찾아서 슈퍼클래스의 생성자를 사용하도록 수정한다.
11. 테스트.
12. 서브클래스를 삭제한다(죽은 코드 제거 8.9).

**예시**
```js
// before
class Booking { constructor(show, date) {} get hasTalkback() { return this._show.hasOwnProperty('talkback') && !this.isPeakDay; } }
class PremiumBooking extends Booking { get hasTalkback() { return this._show.hasOwnProperty('talkback'); } }
// after
class Booking {
  constructor(show, date) { /* ... */ this._premiumDelegate = null; }
  _bePremium(extras) { this._premiumDelegate = new PremiumBookingDelegate(this, extras); }
  get hasTalkback() {
    return this._premiumDelegate ? this._premiumDelegate.hasTalkback : this._show.hasOwnProperty('talkback') && !this.isPeakDay;
  }
}
class PremiumBookingDelegate {
  constructor(hostBooking, extras) { this._host = hostBooking; this._extras = extras; }
  get hasTalkback() { return this._host._show.hasOwnProperty('talkback'); }
}
function createPremiumBooking(show, date, extras) { const r = new Booking(show, date); r._bePremium(extras); return r; }
```

---

## 12.11 슈퍼클래스를 위임으로 바꾸기 (Replace Superclass with Delegate)
- 1판 이름: 상속을 위임으로 바꾸기(Replace Inheritance with Delegation)

**배경**
- 슈퍼클래스의 기능이 서브클래스에 **어울리지 않을 때**(예: `Stack extends List` — 리스트의 모든 연산이 스택에 노출됨; `CarModel extends Car`?) 상속을 끊고 슈퍼클래스 인스턴스를 필드로 갖고 위임한다.
- 위임의 대가: 위임 메서드를 일일이 작성해야 한다. 서브클래스가 슈퍼클래스의 **모든 기능을 자연스럽게 사용**하고 있고 타입 관계가 맞다면 상속이 낫다. **상속을 먼저 쓰고, 문제가 생기면 위임으로.**

**절차**
1. 슈퍼클래스 객체를 참조하는 필드를 서브클래스에 만든다(이 리팩터링을 끝내면 슈퍼클래스가 위임 객체가 된다). 위임 참조를 새로운 슈퍼클래스 인스턴스로 초기화한다.
2. 슈퍼클래스의 동작 각각에 대응하는 전달 함수를 서브클래스에 만든다(물론 위임 참조로 전달한다). 서로 관련된 함수끼리 그룹으로 묶어 진행하며, 그룹을 하나씩 만들 때마다 테스트한다.
3. 슈퍼클래스의 동작 모두가 전달 함수로 오버라이드되었다면 상속 관계를 끊는다.

**예시**
```js
// before
class List {}
class Stack extends List {}
// after
class Stack {
  constructor() { this._storage = new List(); }
  push(x) { this._storage.add(x); }
  pop() { return this._storage.removeLast(); }
}
```
