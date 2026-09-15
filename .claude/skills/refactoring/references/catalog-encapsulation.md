# 7장 캡슐화 (Encapsulation)

모듈을 분리하는 가장 중요한 기준은 "무엇을 숨기는가". 데이터를 감추고, 임시 변수를 없애고, 클래스를 적정 크기로 나눈다.

---

## 7.1 레코드 캡슐화하기 (Encapsulate Record)
- 1판 이름: 레코드를 데이터 클래스로 바꾸기(Replace Record with Data Class)

**배경**
- 가변 데이터를 담는 레코드(공개 필드 객체, 해시맵)는 클래스로 감싸는 것이 낫다. 필드 이름을 숨기고, 저장값과 계산값을 구분할 필요가 없어지고, 동작을 추가하기 쉽다.
- 불변 레코드는 그대로 둬도 된다. 해시맵은 필드가 뭐가 있는지 코드 어디에도 명시되지 않아 넓게 쓰이면 위험.

**절차**
1. 레코드를 담은 변수를 캡슐화(6.6)한다. 함수 이름은 나중에 검색하기 쉽게.
2. 레코드를 감싸는 단순 클래스를 만든다. 원본 레코드를 반환하는 접근자를 두고, 변수 캡슐화 함수가 이 접근자를 쓰게 한다.
3. 테스트.
4. 원본 레코드 대신 새 클래스 인스턴스를 반환하는 함수를 새로 만든다.
5. 레코드를 반환하는 옛 함수의 사용처를 새 함수로 하나씩 바꾼다. 필드 접근은 새 객체의 접근자를 쓰게 하고, 없으면 만든다. 매번 테스트.
   - 중첩 구조라면 **갱신하는 클라이언트**부터 처리하고, 읽기 전용 클라이언트에는 복사본이나 읽기 전용 프락시를 반환하는 것을 고려.
6. 클래스에서 원본 데이터를 반환하던 접근자와 옛 함수를 제거하고 테스트.
7. 레코드의 필드도 데이터 구조인 중첩 구조면 재귀적으로 적용.

**예시**
```js
// before
const organization = { name: '애크미 구스베리', country: 'GB' };
organization.name = newName;
// after
class Organization {
  #name; #country;
  constructor(data) { this.#name = data.name; this.#country = data.country; }
  get name() { return this.#name; }
  set name(v) { this.#name = v; }
  get country() { return this.#country; }
}
```

---

## 7.2 컬렉션 캡슐화하기 (Encapsulate Collection)

**배경**
- 컬렉션 필드의 게터가 컬렉션 자체를 반환하면 클라이언트가 소유 클래스 몰래 원소를 추가·삭제할 수 있다.
- `add`/`remove` 같은 **변경 메서드를 제공**하고, 게터는 **복제본 또는 읽기 전용 뷰**를 반환한다. 세터로 컬렉션 전체를 교체하는 것도 막는다(꼭 필요하면 복제해서 저장).
- 클래스 안에서 컬렉션을 다루는 방식을 **일관되게** 유지하는 것이 핵심.

**절차**
1. 컬렉션 변수가 캡슐화되어 있지 않다면 변수 캡슐화(6.6)한다.
2. 컬렉션에 원소를 추가/제거하는 함수를 클래스에 추가한다. 컬렉션 세터가 있으면 제거(11.7)하거나 복제본을 저장하게 한다.
3. 정적 검사.
4. 컬렉션을 직접 수정하던 곳을 모두 찾아 새 메서드 호출로 바꾼다. 매번 테스트.
5. 컬렉션 게터가 복제본 또는 읽기 전용 프락시를 반환하게 한다.
6. 테스트.

**예시**
```js
// before
class Person { get courses() { return this._courses; } set courses(list) { this._courses = list; } }
aPerson.courses.push(new Course('수학'));
// after
class Person {
  get courses() { return this._courses.slice(); }
  addCourse(c) { this._courses.push(c); }
  removeCourse(c, fn = () => { throw new RangeError(); }) {
    const i = this._courses.indexOf(c);
    if (i === -1) fn(); else this._courses.splice(i, 1);
  }
}
```

---

## 7.3 기본형을 객체로 바꾸기 (Replace Primitive with Object)
- 1판 이름: 데이터 값을 객체로 바꾸기(Replace Data Value with Object), 타입 코드를 클래스로 바꾸기(Replace Type Code with Class)

**배경**
- 처음엔 전화번호를 문자열로 저장해도 되지만, 곧 포맷팅·검증·지역번호 추출 등 동작이 필요해진다. 그때 **값 클래스**를 만들면 그 동작들이 모여 들어간다(기본형 집착 3.11).
- 단순 출력 이상의 동작이 필요해지는 순간 적용한다.

**절차**
1. 아직이라면 변수를 캡슐화(6.6)한다.
2. 단순 값 클래스를 만든다. 생성자는 기존 값을 받고, 그 값을 반환하는 게터를 둔다.
3. 정적 검사.
4. 값 클래스의 인스턴스를 세터가 새로 만들어 필드에 저장하게 한다. 필드 타입을 바꾼다.
5. 게터가 값 클래스의 게터를 호출한 결과를 반환하게 한다.
6. 테스트.
7. 함수 이름을 바꿀지(6.5), 참조를 값으로 바꿀지(9.4) 검토한다.

**예시**
```js
// before
class Order { constructor(data) { this.priority = data.priority; } }
highPriorityCount = orders.filter(o => 'high' === o.priority || 'rush' === o.priority).length;
// after
class Priority {
  constructor(value) { this._value = value; }
  toString() { return this._value; }
  get _index() { return Priority.legalValues().indexOf(this._value); }
  static legalValues() { return ['low', 'normal', 'high', 'rush']; }
  higherThan(other) { return this._index > other._index; }
}
class Order {
  get priority() { return this._priority; }
  set priority(s) { this._priority = new Priority(s); }
}
highPriorityCount = orders.filter(o => o.priority.higherThan(new Priority('normal'))).length;
```

---

## 7.4 임시 변수를 질의 함수로 바꾸기 (Replace Temp with Query)

**배경**
- 임시 변수는 표현식을 반복 계산하지 않게 해 주지만, 함수 안에서만 쓸 수 있다. 함수로 만들면 다른 함수에서도 쓰고, 긴 함수를 추출(6.1)할 때 넘겨야 할 매개변수도 줄어든다.
- **클래스 안**에서 가장 효과적(공통 컨텍스트). 한 번만 계산되고 이후 읽기만 하는 변수가 대상. 여러 번 대입되면 변수 쪼개기(9.1) 먼저.
- 계산 로직에 부작용이 있으면 질의 함수와 변경 함수 분리(11.1) 먼저.

**절차**
1. 변수가 사용되기 전에 값이 확실히 결정되는지, 매번 같은 결과를 내는지 확인.
2. 읽기 전용으로 만들 수 있으면 `const`로 바꾼다.
3. 테스트.
4. 변수 대입문을 함수로 추출(6.1)한다. 이름이 겹치면 함수 이름을 임시로 바꾼다.
5. 테스트.
6. 변수 인라인(6.4)으로 임시 변수를 제거한다.

**예시**
```js
// before
get price() {
  const basePrice = this._quantity * this._itemPrice;
  const discountFactor = basePrice > 1000 ? 0.95 : 0.98;
  return basePrice * discountFactor;
}
// after
get basePrice() { return this._quantity * this._itemPrice; }
get discountFactor() { return this.basePrice > 1000 ? 0.95 : 0.98; }
get price() { return this.basePrice * this.discountFactor; }
```

---

## 7.5 클래스 추출하기 (Extract Class)
- 반대: 클래스 인라인하기(7.6)

**배경**
- 클래스는 명확한 추상 개념 하나만 다뤄야 한다. 메서드와 데이터가 너무 많아졌거나(거대한 클래스 3.20), 데이터 일부가 항상 같이 변경되거나 서로 의존하면 분리한다.
- 힌트: 함께 사라져도 되는 필드·메서드 묶음, 서브클래스가 특정 기능에만 영향을 주는 경우.

**절차**
1. 클래스의 역할을 어떻게 나눌지 정한다.
2. 분리될 역할을 담을 새 클래스를 만든다(이름이 안 맞으면 원 클래스 이름도 바꾼다).
3. 원 클래스 생성자에서 새 클래스 인스턴스를 만들어 필드에 저장한다.
4. 분리할 필드를 하나씩 새 클래스로 옮긴다(8.2). 매번 테스트.
5. 메서드를 새 클래스로 옮긴다(8.1). 저수준 메서드(다른 메서드에서 호출되는 것)부터. 매번 테스트.
6. 양쪽 클래스의 인터페이스를 살펴 불필요한 메서드를 제거하고 이름을 새 환경에 맞게 바꾼다.
7. 새 클래스를 외부로 노출할지 결정한다. 노출한다면 참조를 값으로 바꾸기(9.4) 검토.

**예시**
```js
// before
class Person {
  get officeAreaCode() { return this._officeAreaCode; }
  get officeNumber() { return this._officeNumber; }
}
// after
class Person {
  get officeAreaCode() { return this._telephoneNumber.areaCode; }
  get officeNumber() { return this._telephoneNumber.number; }
}
class TelephoneNumber {
  get areaCode() { return this._areaCode; }
  get number() { return this._number; }
}
```

---

## 7.6 클래스 인라인하기 (Inline Class)
- 반대: 클래스 추출하기(7.5)

**배경**
- 역할이 거의 남지 않은 클래스(리팩터링으로 쪼그라든 결과)를 가장 많이 쓰는 클래스로 흡수시킨다.
- 두 클래스의 기능을 **재배치**하고 싶을 때, 일단 하나로 합친 뒤 새로 추출(7.5)하는 것이 더 쉬울 때가 있다.

**절차**
1. 소스 클래스의 public 메서드 각각에 대응하는 메서드를 타깃 클래스에 만든다. 처음엔 소스 클래스로 위임만.
2. 소스 클래스 메서드를 사용하던 코드를 모두 타깃 클래스의 위임 메서드로 바꾼다. 매번 테스트.
3. 소스 클래스의 메서드와 필드를 모두 타깃으로 옮긴다. 매번 테스트.
4. 소스 클래스를 삭제한다.

**예시**
```js
// before
class Shipment { get trackingInfo() { return this._trackingInformation.display; } }
class TrackingInformation { get display() { return `${this.shippingCompany}: ${this.trackingNumber}`; } }
// after
class Shipment { get trackingInfo() { return `${this.shippingCompany}: ${this.trackingNumber}`; } }
```

---

## 7.7 위임 숨기기 (Hide Delegate)
- 반대: 중개자 제거하기(7.8)

**배경**
- 클라이언트가 `person.department.manager`처럼 위임 객체를 직접 탐색하면 위임 객체의 인터페이스에 결합된다(메시지 체인 3.17).
- 서버에 위임 메서드를 두면 클라이언트는 위임 객체의 존재를 몰라도 되고, 나중에 관계가 바뀌어도 서버만 고치면 된다.

**절차**
1. 위임 객체의 각 메서드에 대응하는 위임 메서드를 서버에 만든다.
2. 클라이언트가 위임 객체 대신 서버를 호출하게 바꾼다. 매번 테스트.
3. 모두 수정했으면 서버에서 위임 객체를 반환하는 접근자를 제거한다.
4. 테스트.

**예시**
```js
// before
manager = aPerson.department.manager;
// after
class Person { get manager() { return this._department.manager; } }
manager = aPerson.manager;
```

---

## 7.8 중개자 제거하기 (Remove Middle Man)
- 반대: 위임 숨기기(7.7)

**배경**
- 위임 메서드가 너무 많아지면 서버 클래스가 단순 **중개자**(3.18)가 된다. 이때는 클라이언트가 위임 객체를 직접 쓰게 한다.
- 얼마나 숨겨야 적당한지의 정답은 없다. 시간이 지나며 균형을 조정한다 — 두 기법은 상호 보완.

**절차**
1. 위임 객체를 얻는 게터를 만든다.
2. 위임 메서드를 호출하는 클라이언트가 게터를 거쳐 위임 객체를 직접 호출하게 바꾼다. 매번 테스트.
3. 모두 수정했으면 위임 메서드를 삭제한다.
- 디미터 법칙(Law of Demeter)은 "가끔 유용한 제안" 정도로 받아들인다.

**예시**
```js
// before
manager = aPerson.manager;
class Person { get manager() { return this._department.manager; } }
// after
manager = aPerson.department.manager;
```

---

## 7.9 알고리즘 교체하기 (Substitute Algorithm)

**배경**
- 같은 결과를 내는 더 간단한 방법이 있으면 통째로 바꾼다. 라이브러리로 대체할 수 있을 때, 알고리즘을 바꾸고 싶을 때.
- 교체하려면 먼저 **메서드를 최대한 잘게** 나눠 두어야 한다. 복잡한 알고리즘은 통째로 교체하기 어렵다.

**절차**
1. 교체할 코드를 함수 하나에 모은다.
2. 이 함수만을 검증하는 테스트를 마련한다.
3. 대체 알고리즘을 작성한다.
4. 정적 검사.
5. 기존 알고리즘과 새 알고리즘의 결과를 비교하는 테스트를 수행한다. 같으면 완료. 다르면 옛 알고리즘을 참고해 디버깅.

**예시**
```js
// before
function foundPerson(people) {
  for (let i = 0; i < people.length; i++) {
    if (people[i] === 'Don') return 'Don';
    if (people[i] === 'John') return 'John';
    if (people[i] === 'Kent') return 'Kent';
  }
  return '';
}
// after
function foundPerson(people) {
  const candidates = ['Don', 'John', 'Kent'];
  return people.find(p => candidates.includes(p)) || '';
}
```
