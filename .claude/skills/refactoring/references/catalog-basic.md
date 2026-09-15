# 6장 기본적인 리팩터링 (Basic Refactorings)

가장 자주 쓰는 기법들. 함수 추출·인라인, 변수 추출·인라인, 이름 바꾸기가 리팩터링의 대부분을 차지한다.
각 항목: **배경(언제)** → **절차(작은 단계, 단계마다 테스트)** → **예시**.

---

## 6.1 함수 추출하기 (Extract Function)
- 1판 이름: 메서드 추출하기(Extract Method) · 반대: 함수 인라인하기(6.2)

**배경**
- 기준은 길이가 아니라 **"목적과 구현의 분리"**. 코드를 보고 무슨 일을 하는지 파악하는 데 시간이 걸리면, 그 부분을 추출해 **무엇을 하는지** 이름으로 드러낸다.
- 한 줄짜리라도 이름이 코드보다 의도를 잘 드러내면 추출한다. 호출 오버헤드는 현대 언어에서 무시해도 된다.
- 짧은 함수가 많은 코드가 오래 살아남는다. 단, **이름이 좋아야** 한다.

**절차**
1. 새 함수를 만들고 **목적을 드러내는 이름**을 붙인다("어떻게"가 아니라 "무엇을"). 이름이 안 떠오르면 추출하지 않는다는 신호.
2. 추출할 코드를 원본에서 새 함수로 복사한다.
3. 원본의 지역 변수 중 새 함수에서 쓰는 것은 매개변수로 넘긴다. 새 함수 안에서만 쓰는 변수는 새 함수의 지역 변수로.
4. 추출 코드에서 **값이 바뀌는 지역 변수**가 원본에서 이후에도 쓰이면 반환값으로 돌려준다. 그런 변수가 둘 이상이면 먼저 변수 쪼개기(9.1)/임시 변수를 질의 함수로(7.4)로 줄이거나, 더 작게 추출한다.
5. 컴파일/린트.
6. 원본의 해당 코드를 새 함수 호출로 교체한다.
7. 테스트.
8. 같은 코드가 다른 곳에도 있는지 찾아 새 함수 호출로 바꿀지 검토한다(인라인 코드를 함수 호출로 바꾸기 8.5).

**예시**
```js
// before
function printOwing(invoice) {
  printBanner();
  const outstanding = calculateOutstanding(invoice);
  // 세부 사항 출력
  console.log(`고객명: ${invoice.customer}`);
  console.log(`채무액: ${outstanding}`);
}
// after
function printOwing(invoice) {
  printBanner();
  const outstanding = calculateOutstanding(invoice);
  printDetails(invoice, outstanding);
}
function printDetails(invoice, outstanding) {
  console.log(`고객명: ${invoice.customer}`);
  console.log(`채무액: ${outstanding}`);
}
```

---

## 6.2 함수 인라인하기 (Inline Function)
- 1판 이름: 메서드 인라인하기 · 반대: 함수 추출하기(6.1)

**배경**
- 본문이 이름만큼이나 명확할 때(성의 없는 요소 3.14). 간접 호출이 과도할 때(중개자 3.18).
- 잘못 추출된 함수들을 일단 하나로 합친 뒤 다시 잘 추출하려 할 때(산탄총 수술 3.8 대응).

**절차**
1. 다형 메서드(오버라이드되는 메서드)인지 확인 — 그렇다면 인라인하지 않는다.
2. 호출하는 곳을 모두 찾는다.
3. 각 호출을 함수 본문으로 교체한다. 하나 교체할 때마다 테스트. 한꺼번에 하지 않는다.
4. 함수 정의를 삭제한다.
- 어려운 인라인(재귀, 반환 지점 여러 개, 다른 객체의 접근자 등)은 하지 않는 게 낫다.

**예시**
```js
// before
function getRating(driver) { return moreThanFiveLateDeliveries(driver) ? 2 : 1; }
function moreThanFiveLateDeliveries(driver) { return driver.numberOfLateDeliveries > 5; }
// after
function getRating(driver) { return driver.numberOfLateDeliveries > 5 ? 2 : 1; }
```

---

## 6.3 변수 추출하기 (Extract Variable)
- 1판 이름: 설명용 변수 도입(Introduce Explaining Variable) · 반대: 변수 인라인하기(6.4)

**배경**
- 복잡한 표현식의 일부에 이름을 붙여 **의미 단위로 읽히게** 한다. 디버깅에도 좋다(중단점 잡기 쉬움).
- 이름이 그 함수 안에서만 의미 있으면 변수, 더 넓은 문맥에서 의미 있으면 **함수 추출**(6.1)이 낫다. 클래스 안이라면 메서드로 추출하는 편이 다른 메서드도 재사용할 수 있어 유리.

**절차**
1. 추출할 표현식에 부작용이 없는지 확인.
2. 불변 변수를 선언하고 표현식을 대입.
3. 원본 표현식을 새 변수로 교체.
4. 테스트. 같은 표현식이 여러 곳이면 하나씩 교체하며 테스트.

**예시**
```js
// before
return order.quantity * order.itemPrice
  - Math.max(0, order.quantity - 500) * order.itemPrice * 0.05
  + Math.min(order.quantity * order.itemPrice * 0.1, 100);
// after
const basePrice = order.quantity * order.itemPrice;
const quantityDiscount = Math.max(0, order.quantity - 500) * order.itemPrice * 0.05;
const shipping = Math.min(basePrice * 0.1, 100);
return basePrice - quantityDiscount + shipping;
```

---

## 6.4 변수 인라인하기 (Inline Variable)
- 1판 이름: 임시 변수 인라인 · 반대: 변수 추출하기(6.3)

**배경**
- 변수 이름이 표현식과 다를 바 없을 때. 주변 코드를 리팩터링하는 데 변수가 방해될 때.

**절차**
1. 대입문의 우변에 부작용이 없는지 확인.
2. 변수가 불변으로 선언되지 않았다면 불변으로 바꾸고 테스트(한 번만 대입되는지 확인).
3. 변수를 처음 사용하는 곳을 표현식으로 교체. 테스트.
4. 나머지 사용처도 같은 방식으로. 변수 선언과 대입문 삭제. 테스트.

**예시**
```js
// before
const basePrice = anOrder.basePrice;
return basePrice > 1000;
// after
return anOrder.basePrice > 1000;
```

---

## 6.5 함수 선언 바꾸기 (Change Function Declaration)
- 통합된 1판 이름: 함수 이름 바꾸기(Rename Function/Method), 매개변수 추가(Add Parameter), 매개변수 제거(Remove Parameter), 시그니처 바꾸기(Change Signature)

**배경**
- 함수는 프로그램을 잇는 이음매. 이름이 나쁘면 의도가 안 보이고, 매개변수가 잘못되면 결합도가 높아진다.
- 이름 짓기 팁: 함수가 하는 일을 **주석 한 줄**로 써 보고, 그것을 이름으로 바꾼다.
- 매개변수는 "이 함수를 어떤 맥락에서 쓸 수 있게 할 것인가"를 결정한다(예: 전화번호 포맷 함수가 `Person`을 받으면 사람에게만, 문자열을 받으면 어디서든 쓸 수 있다).

**절차 — 간단한 방법**(호출자가 적고 도구 지원이 있을 때)
1. 매개변수를 제거한다면 함수 본문에서 그 매개변수를 참조하는 곳이 없는지 확인.
2. 선언을 바꾼다.
3. 호출하는 곳을 모두 찾아 새 형태로 바꾼다.
4. 테스트.
- 이름과 매개변수를 동시에 바꾸지 말고 **하나씩**.

**절차 — 마이그레이션 방법**(호출자가 많거나 공개 API일 때)
1. 필요하면 본문을 먼저 리팩터링해서 추출하기 쉽게 만든다.
2. 본문을 **새 이름의 새 함수**로 추출한다(6.1). 이름이 겹치면 임시 이름.
3. 새 함수가 새 매개변수를 받게 하고, 옛 함수는 새 함수를 **호출만** 하도록 만든다.
4. 테스트.
5. 옛 함수를 호출하던 곳을 하나씩 새 함수로 바꾼다. 매번 테스트.
6. 옛 함수를 제거하거나(공개 API면) `@deprecated`로 표시해 남긴다.

**예시**
```js
// before
function circum(radius) { return 2 * Math.PI * radius; }
// 마이그레이션: 새 함수를 추출하고 옛 함수는 위임
function circum(radius) { return circumference(radius); }
function circumference(radius) { return 2 * Math.PI * radius; }
// after: 호출자 전부 옮긴 뒤 circum 삭제
```

---

## 6.6 변수 캡슐화하기 (Encapsulate Variable)
- 1판 이름: 필드 캡슐화(Encapsulate Field), 필드 자기 캡슐화(Self-Encapsulate Field)

**배경**
- 함수는 옮기기 쉽지만 데이터는 옮기기 어렵다(참조하는 곳을 모두 바꿔야 한다). 접근 범위가 넓은 데이터일수록 **접근 함수로 감싸서** 변경·검증 로직을 한곳에 둔다.
- 전역 데이터(3.5)에 대한 첫 수. 가변 데이터(3.6)에도 유효. 불변 데이터는 캡슐화할 필요가 적다.
- 게터가 원본 참조를 그대로 돌려주면 외부에서 내부를 바꿀 수 있다. 값을 복사해 돌려주거나(복제) 레코드 캡슐화(7.1)로 대응.

**절차**
1. 변수로의 접근과 갱신을 담당하는 캡슐화 함수(게터/세터)를 만든다.
2. 정적 검사(참조 검색).
3. 변수를 직접 참조하던 곳을 모두 접근 함수 호출로 바꾼다. 하나 바꿀 때마다 테스트.
4. 변수의 접근 범위를 제한한다(모듈 비공개, `private`).
5. 테스트.
6. 변수 값이 레코드라면 레코드 캡슐화(7.1) 검토.

**예시**
```js
// before
let defaultOwner = { firstName: '마틴', lastName: '파울러' };
spaceship.owner = defaultOwner;
defaultOwner = { firstName: '레베카', lastName: '파슨스' };
// after
let defaultOwnerData = { firstName: '마틴', lastName: '파울러' };
export function defaultOwner() { return { ...defaultOwnerData }; } // 복제해서 반환
export function setDefaultOwner(arg) { defaultOwnerData = arg; }
spaceship.owner = defaultOwner();
setDefaultOwner({ firstName: '레베카', lastName: '파슨스' });
```

---

## 6.7 변수 이름 바꾸기 (Rename Variable)

**배경**
- 좋은 이름은 프로그래밍의 핵심. 넓은 범위에서 쓰이는 변수일수록 이름이 중요하다.
- 한 줄짜리 람다 매개변수는 한 글자여도 괜찮다. 필드는 특히 신중히.

**절차**
1. 변수가 넓게 쓰인다면 먼저 변수 캡슐화(6.6)를 고려한다.
2. 변수를 참조하는 곳을 모두 찾아 하나씩 바꾼다.
   - 다른 코드베이스에서 참조하는 변수(공개)라면 바꾸지 않거나, 캡슐화하고 새 이름의 접근 함수를 제공한다.
   - 변수 값이 바뀌지 않는다면 새 이름으로 복사본을 만들어 점진 전환할 수 있다.
3. 테스트.

**예시**
```js
// before
let a = height * width;
// after
let area = height * width;
```

---

## 6.8 매개변수 객체 만들기 (Introduce Parameter Object)

**배경**
- 데이터 뭉치(3.10)가 여러 함수에 매개변수로 함께 다닌다. 묶으면 매개변수 수가 줄고, 같은 데이터를 쓰는 함수들이 **일관된 이름**을 쓰게 된다.
- 진짜 효과는 이 자료구조가 **새로운 추상 개념**이 되어 관련 동작을 끌어당길 때 나타난다(예: `{min, max}` → `NumberRange.contains(n)`).

**절차**
1. 적당한 자료구조가 없다면 만든다. **클래스**(값 객체, 불변)로 만드는 것을 권장.
2. 테스트.
3. 함수 선언 바꾸기(6.5)로 새 자료구조를 매개변수로 추가한다.
4. 테스트.
5. 호출하는 곳마다 새 자료구조 인스턴스를 넘기도록 수정. 매번 테스트.
6. 기존 매개변수를 사용하던 코드를 새 자료구조의 원소를 쓰도록 바꾼다.
7. 다 옮겼으면 기존 매개변수를 제거하고 테스트.

**예시**
```js
// before
function amountInvoiced(startDate, endDate) {}
function amountReceived(startDate, endDate) {}
// after
class DateRange { constructor(start, end) { this.start = start; this.end = end; } }
function amountInvoiced(aDateRange) {}
function amountReceived(aDateRange) {}
```

---

## 6.9 여러 함수를 클래스로 묶기 (Combine Functions into Class)

**배경**
- 같은 데이터(보통 같은 레코드)를 인수로 받아 다루는 함수들이 여럿이면 클래스로 묶는다. 공통 환경이 명확해지고, 인수가 줄고, 객체를 넘기기만 하면 된다.
- 대안은 변환 함수로 묶기(6.10). 클래스는 원본 데이터가 **갱신될 때** 더 유리하다(파생값이 자동으로 갱신). 파생값을 미리 계산한 레코드는 갱신 시 불일치가 생긴다.
- 함수형 스타일이라면 클로저로 같은 효과.

**절차**
1. 함수들이 공유하는 공통 데이터 레코드를 캡슐화(7.1)한다.
2. 공통 레코드를 사용하는 함수 각각을 새 클래스로 옮긴다(8.1). 공통 데이터는 인수에서 제거.
3. 데이터를 조작하는 로직들을 함수로 추출(6.1)해서 새 클래스로 옮긴다.

**예시**
```js
// before
function base(aReading) {}
function taxableCharge(aReading) {}
function calculateBaseCharge(aReading) {}
// after
class Reading {
  base() {}
  taxableCharge() {}
  calculateBaseCharge() {}
}
```

---

## 6.10 여러 함수를 변환 함수로 묶기 (Combine Functions into Transform)

**배경**
- 원본 데이터에서 파생값을 계산하는 함수가 여기저기 흩어져 있다. 한 **변환 함수**가 원본을 받아 파생값을 모두 채운 **새 레코드**를 반환하게 한다. 파생 로직이 한곳에 모이고 중복이 사라진다.
- 원본이 갱신되는 코드에서는 클래스로 묶기(6.9)가 안전하다.

**절차**
1. 변환할 레코드를 입력받아 **깊은 복사**해 반환하는 변환 함수를 만든다.
2. 테스트.
3. 파생 계산 로직 하나를 골라 변환 함수 안으로 옮기고, 결과를 반환 레코드의 새 필드에 기록한다.
4. 테스트.
5. 원본 계산 함수를 쓰던 클라이언트가 새 필드를 쓰게 바꾼다.
6. 다른 파생 로직에 대해 반복.

**예시**
```js
// before
function base(aReading) {}
function taxableCharge(aReading) {}
// after
function enrichReading(argReading) {
  const aReading = _.cloneDeep(argReading);
  aReading.baseCharge = base(aReading);
  aReading.taxableCharge = taxableCharge(aReading);
  return aReading;
}
```

---

## 6.11 단계 쪼개기 (Split Phase)

**배경**
- 서로 다른 두 대상을 한 코드에서 다루고 있으면 **순차적인 단계**로 분리한다(컴파일러의 토크나이징→파싱→코드생성처럼). 각 단계는 자기 문제에만 집중하고, 단계 사이는 **중간 자료구조**로 소통.
- 뒤엉킨 변경(3.7) 대응. 명령줄 인수 파싱 → 실행처럼 "입력 해석"과 "본 처리"를 나눌 때 흔히 쓴다.

**절차**
1. 두 번째 단계에 해당하는 코드를 독립 함수로 추출(6.1)한다.
2. 테스트.
3. 중간 자료구조를 만들어 앞 단계에서 만들고 뒤 단계 함수에 인수로 넘긴다.
4. 테스트.
5. 추출한 두 번째 단계 함수의 매개변수를 하나씩 검토한다. 첫 단계에서 쓰인 것이면 중간 자료구조로 옮긴다. 옮길 때마다 테스트.
6. 첫 번째 단계 코드를 함수로 추출(6.1)하고 중간 자료구조를 반환하게 한다.
- 중간 자료구조는 변환 함수(6.10)로 만드는 것도 좋다.

**예시**
```js
// before
const orderData = orderString.split(/\s+/);
const productPrice = priceList[orderData[0].split('-')[1]];
const orderPrice = parseInt(orderData[1]) * productPrice;
// after
const orderRecord = parseOrder(orderString);
const orderPrice = price(orderRecord, priceList);

function parseOrder(aString) {
  const values = aString.split(/\s+/);
  return { productID: values[0].split('-')[1], quantity: parseInt(values[1]) };
}
function price(order, priceList) {
  return order.quantity * priceList[order.productID];
}
```
