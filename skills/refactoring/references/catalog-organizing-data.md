# 9장 데이터 조직화 (Organizing Data)

변수·필드·리터럴 등 데이터 요소를 정리한다. 한 변수는 한 가지 목적으로만.

---

## 9.1 변수 쪼개기 (Split Variable)
- 1판 이름: 임시 변수 분리(Split Temp), 매개변수로의 값 대입 제거(Remove Assignments to Parameters)

**배경**
- 반복문 변수나 누적 변수(collecting variable)는 여러 번 대입되는 게 자연스럽다. 그 외에 **한 변수에 두 가지 이상의 역할**로 값이 대입되면 쪼갠다. 역할이 둘이면 이름도 둘이어야 한다.
- 입력 매개변수에 값을 대입하는 것도 이 악취(호출자의 값을 바꾸는지 헷갈림) → 새 변수를 만든다.

**절차**
1. 변수를 선언한 곳과 값을 처음 대입하는 곳에서 변수 이름을 바꾼다.
2. 가능하면 불변(`const`)으로 선언한다.
3. 이 변수에 **두 번째로 값을 대입하는 곳 앞까지**의 모든 참조를 새 이름으로 바꾼다.
4. 두 번째 대입 시 변수를 원래 이름으로 다시 선언한다.
5. 테스트.
6. 반복한다. 매번 선언부에서 변수 이름을 바꾸고 다음 대입 전까지 참조를 수정한다.

**예시**
```js
// before
let temp = 2 * (height + width);
console.log(temp);
temp = height * width;
console.log(temp);
// after
const perimeter = 2 * (height + width);
console.log(perimeter);
const area = height * width;
console.log(area);
```

---

## 9.2 필드 이름 바꾸기 (Rename Field)

**배경**
- 자료구조는 프로그램을 이해하는 열쇠. 레코드 필드 이름(클래스의 게터/세터 포함)이 데이터의 의미를 정확히 전달해야 한다.
- 레코드가 캡슐화되어 있으면 쉽다.

**절차**
1. 레코드의 유효 범위가 제한적이면 필드에 접근하는 모든 코드를 수정하고 테스트. 끝.
2. 레코드가 캡슐화되지 않았다면 먼저 레코드를 캡슐화(7.1)한다.
3. 캡슐화된 객체 안의 private 필드 이름을 바꾸고, 내부 메서드들을 수정한다.
4. 테스트.
5. 생성자의 매개변수 중 필드와 이름이 겹치는 것이 있으면 함수 선언 바꾸기(6.5)로 변경.
6. 접근자 이름도 바꾼다(6.5).

**예시**
```js
// before
class Organization { get name() {} }
// after
class Organization { get title() {} }
```

---

## 9.3 파생 변수를 질의 함수로 바꾸기 (Replace Derived Variable with Query)

**배경**
- 가변 데이터는 문제의 근원(3.6). **계산으로 얻을 수 있는 값은 저장하지 말고 계산한다.** 계산 자체가 데이터의 의미를 더 잘 설명하기도 한다.
- 예외: 원본 데이터가 불변이고 파생 데이터도 불변이면 저장해도 된다. 변형 연산(transformation)을 적용할 때도 마찬가지.

**절차**
1. 변수 값이 갱신되는 지점을 모두 찾는다. 필요하면 변수 쪼개기(9.1)로 갱신 지점을 분리.
2. 해당 변수의 값을 계산해 주는 함수를 만든다.
3. 변수를 읽는 곳마다 **어서션을 추가**(10.6)해 함수 결과와 변수 값이 같은지 확인한다(아직 읽는 코드는 바꾸지 않는다).
4. 테스트. 어서션이 통과하면 두 값이 동등함이 증명된 것.
5. 변수를 읽는 코드를 모두 함수 호출로 대체하고 어서션을 제거한다.
6. 테스트.
7. 변수 선언과 갱신 코드를 죽은 코드 제거(8.9)로 없앤다.

**예시**
```js
// before
get discountedTotal() { return this._discountedTotal; }
set discount(n) { const old = this._discount; this._discount = n; this._discountedTotal += old - n; }
// after
get discountedTotal() { return this._baseTotal - this._discount; }
set discount(n) { this._discount = n; }
```

---

## 9.4 참조를 값으로 바꾸기 (Change Reference to Value)
- 반대: 값을 참조로 바꾸기(9.5)

**배경**
- 객체를 다른 객체에 중첩할 때, 내부 객체를 **참조**로 다루면 내부 객체의 속성을 갱신하고, **값**으로 다루면 새 객체로 통째로 교체한다.
- 값 객체(Value Object)는 불변이라 공유해도 안전하고, 분산·동시성 시스템에서 특히 유용하다.
- 값 객체는 **동등성 비교**(`equals`, `hashCode`)를 필드 값 기반으로 정의해야 한다.
- 특정 객체를 여러 곳에서 공유하며 갱신을 전파해야 한다면 참조로 두어야 한다(9.5).

**절차**
1. 후보 클래스가 불변인지, 불변으로 만들 수 있는지 확인.
2. 각 세터를 하나씩 제거(11.7)한다.
3. 값 기반 동등성 비교 메서드를 만든다(해시 함수도 함께).

**예시**
```js
// before
class Product { applyDiscount(arg) { this._price.amount -= arg; } }
// after
class Product { applyDiscount(arg) { this._price = new Money(this._price.amount - arg, this._price.currency); } }
```

---

## 9.5 값을 참조로 바꾸기 (Change Value to Reference)
- 반대: 참조를 값으로 바꾸기(9.4)

**배경**
- 같은 논리적 엔티티(예: 고객)를 여러 레코드가 각각 **복사본**으로 갖고 있으면, 갱신 시 모든 복사본을 찾아 바꿔야 해서 불일치가 생긴다. 이럴 땐 하나의 참조 객체를 공유한다.
- 참조 객체를 관리하려면 **저장소(repository)** 가 필요하다. 보통 식별자로 찾는 조회 함수(`registry.get(id)`).

**절차**
1. 같은 부류에 속하는 객체들을 보관할 저장소를 만든다(없다면).
2. 생성자에서 이 부류의 객체들 중 특정 객체를 정확히 찾아내는 방법이 있는지 확인.
3. 호스트 객체의 생성자들이 저장소에서 필요한 객체를 찾도록 수정한다. 매번 테스트.

**예시**
```js
// before
class Order {
  constructor(data) { this._customer = new Customer(data.customerId); }
}
// after
const registry = new Map();
function registerCustomer(id) { if (!registry.has(id)) registry.set(id, new Customer(id)); return registry.get(id); }
class Order {
  constructor(data) { this._customer = registerCustomer(data.customerId); }
}
```

---

## 9.6 매직 리터럴 바꾸기 (Replace Magic Literal)
- 1판 이름: 매직 넘버를 기호 상수로 바꾸기(Replace Magic Number with Symbolic Constant)

**배경**
- 코드 곳곳의 `9.81`, `"M"` 같은 리터럴은 의미가 드러나지 않는다. 이름 붙인 상수로 바꾼다(`STANDARD_GRAVITY`).
- 리터럴이 **비교 대상**으로 쓰일 때는 상수보다 **함수**가 낫다: `aValue === "M"` → `isMale(aValue)`.
- 지나치게 일반적인 상수(`ONE = 1`)는 의미가 없다. 리터럴 자체가 이해하기 쉬우면 두어도 된다.

**절차**
1. 상수를 선언하고 매직 리터럴을 대입한다.
2. 해당 리터럴이 사용되는 곳을 모두 찾는다.
3. 찾은 곳이 **같은 의미**로 쓰였는지 확인하고, 그렇다면 상수로 대체하고 테스트.

**예시**
```js
// before
function potentialEnergy(mass, height) { return mass * 9.81 * height; }
// after
const STANDARD_GRAVITY = 9.81;
function potentialEnergy(mass, height) { return mass * STANDARD_GRAVITY * height; }
```
