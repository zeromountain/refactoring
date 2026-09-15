# 기법 연쇄 레시피 (Recipes)

카탈로그의 기법은 하나씩 쓰이는 일이 드물다. 전문가는 **어떤 순서로 이어 붙이는지**, **왜 그 순서인지**,
**어디서 커밋하는지**를 안다. 아래는 자주 만나는 상황별 표준 연쇄다. 번호는 카탈로그 절.

공통 규칙
- 각 화살표(→)마다 테스트를 돌리고, 초록이면 커밋할 수 있는 지점이다. 커밋 메시지에 기법 이름을 적는다(`refactor: 함수 추출 — calculateTotal`).
- 연쇄 앞부분은 대개 **"풀어주는" 기법**(이름 바꾸기·문장 슬라이드·변수 추출·함수 추출)이다. 뒤의 큰 기법을 가능하게 만드는 준비 단계이므로 건너뛰지 않는다.
- 연쇄 도중 멈춰도 코드는 이전보다 나아야 한다. 그렇지 않은 순서는 잘못된 순서다.

---

## R1. 긴 함수 분해

```
문장 슬라이드(8.6)  ─ 관련 문장을 붙여 놓는다. 변수 선언은 첫 사용 직전으로.
→ 변수 추출(6.3)   ─ 복잡한 표현식에 이름을 붙인다(추출할 덩어리가 드러남).
→ 임시 변수를 질의 함수로(7.4) ─ 추출을 방해하는 임시 변수를 없앤다. 클래스 안이면 특히 효과적.
→ 함수 추출(6.1) × N ─ 주석·빈 줄·조건문·반복문 경계마다 하나씩. 이름이 안 떠오르면 덩어리가 잘못됐다는 뜻.
→ 반복문 쪼개기(8.7) → 반복문을 파이프라인으로(8.8) ─ 한 반복문이 두 가지를 세고 있을 때.
→ 매개변수가 5개 넘게 생기면: 매개변수 객체(6.8) / 객체 통째로 넘기기(11.4) / (최후) 함수를 명령으로(11.9)
```
- 함수 추출 전에 임시 변수를 정리하는 이유: 추출한 함수에 임시 변수를 인수·반환값으로 넘기기 시작하면 원본보다 읽기 어려워진다.
- "함수를 명령으로"는 지역 변수를 필드로 바꿔 추출을 쉽게 만드는 우회로다. 일급 함수가 있는 언어에서는 클로저로 같은 효과를 낼 때가 많다.

## R2. 조건부 로직 → 다형성

```
조건문 분해(10.1) 또는 함수 추출(6.1) ─ 분기 로직을 "하나의 함수"로 만든다(다형성은 함수 단위로 갈아 끼우는 것이므로).
→ 생성자를 팩터리 함수로(11.8) ─ 서브클래스를 고를 수 있는 생성 지점을 확보. 이게 없으면 다음 단계가 막힌다.
→ 타입 코드를 서브클래스로(12.6) ─ 타입 코드 하나당 서브클래스 하나. 각 서브클래스는 처음엔 타입 코드 게터만 오버라이드.
→ 함수 옮기기(8.1) ─ 조건부 로직 함수를 슈퍼클래스로.
→ 조건부 로직을 다형성으로(10.4) ─ 분기 하나씩 서브클래스로 옮기고, 슈퍼클래스에는 기본 동작만 남긴다.
→ 죽은 코드 제거(8.9) ─ switch가 비면 지운다.
```
- 언제 하지 말아야 하나: 같은 타입 코드로 분기하는 곳이 **한 군데**뿐이면 다형성은 과잉이다(반복되는 switch 3.12가 아니면 그냥 둔다).
- 상속이 안 맞는 언어/상황(Go, Rust, 함수형)에서는 서브클래스 대신 인터페이스 구현체·sum type + match·전략 객체 맵이 같은 자리를 채운다(`language-notes.md`).
- 타입 코드가 실행 중에 바뀔 수 있으면 직접 상속이 아니라 **간접 상속**(타입 객체를 필드로)을 택한다(12.6 배경).

## R3. 스크립트성 코드 → 단계 쪼개기

```
함수 추출(6.1) ─ "입력 해석"과 "본 계산"과 "출력 조립"을 각각 함수로 잘라낸다(처음엔 매개변수가 많아도 괜찮다).
→ 단계 쪼개기(6.11) ─ 단계 사이에 중간 자료구조를 도입하고, 뒤 단계의 매개변수를 하나씩 그 구조로 옮긴다.
→ 여러 함수를 변환 함수로(6.10) 또는 클래스로(6.9) ─ 중간 자료구조를 채우는 파생 계산을 한곳으로.
```
- 전형적 신호: 파싱 코드와 도메인 계산이 한 함수에, 또는 계산과 문자열 포맷팅(HTML/텍스트)이 섞여 있음.
- 중간 자료구조는 불변 결과 레코드다. 데이터 클래스(3.22)의 예외 사례이므로 게터로 감쌀 필요 없다.
- 출력 형식이 둘 이상 필요해지는 순간(텍스트 + HTML) 이 레시피의 가치가 드러난다: 계산 단계는 그대로, 렌더링 함수만 추가.

## R4. 데이터 클래스 → 진짜 객체

```
레코드 캡슐화(7.1) ─ public 필드를 접근자 뒤로.
→ 세터 제거(11.7) ─ 생성 후 바뀌지 않는 필드부터. 세터의 클라이언트를 찾는 과정에서 잘못된 갱신 지점이 드러난다.
→ 함수 옮기기(8.1) ─ 클라이언트에서 게터를 여러 개 부르는 함수(기능 편애 3.9)를 데이터 클래스 안으로.
→ 함수 추출(6.1) → 함수 옮기기 ─ 통째로 옮길 수 없으면 편애하는 부분만 잘라서.
→ 파생 변수를 질의 함수로(9.3) ─ 저장하던 파생값을 계산으로.
```
- 결과: 데이터와 그 데이터를 다루는 동작이 한곳에. 이후 기본형 집착(3.11)이 보이면 R5로 이어진다.

## R5. 기본형 집착 → 값 객체

```
변수 캡슐화(6.6) ─ 대상 필드를 접근자 뒤로.
→ 기본형을 객체로(7.3) ─ 값 클래스 도입. 처음엔 문자열/숫자를 감싸기만.
→ 함수 옮기기(8.1) ─ 그 값을 다루는 로직(포맷·검증·비교)을 값 클래스로.
→ 참조를 값으로(9.4) ─ 불변 + 값 기반 동등성. 세터 제거(11.7) 포함.
→ (타입 코드였다면) R2로.
```
- 신호: 같은 문자열/숫자에 대한 검증·포맷 코드가 여러 곳에 흩어져 있음, 단위 없는 수량 계산, `a < upper && a > lower` 반복.

## R6. 산탄총 수술 수습

```
함수 인라인(6.2) / 클래스 인라인(7.6) ─ 흩어진 조각을 일단 한곳으로 **모은다**. 중간 결과로 긴 함수·거대한 클래스가 생겨도 괜찮다.
→ 문장 슬라이드(8.6) ─ 모인 코드 안에서 관련 문장을 붙인다.
→ 함수 추출(6.1) / 클래스 추출(7.5) ─ 올바른 경계로 **다시 나눈다**.
→ 함수 옮기기(8.1) / 필드 옮기기(8.2) ─ 새 경계에 맞게 배치.
```
- "잘못 나뉜 것을 다시 나누려면 먼저 합쳐야 한다"는 원칙. 인라인 단계에서 테스트가 초록인 것을 확인하고 커밋한 뒤 다시 추출한다.

## R7. 상속 → 위임

```
생성자를 팩터리 함수로(11.8) ─ 생성 지점을 하나로.
→ 서브클래스를 위임으로(12.10) ─ 서브클래스의 메서드를 하나씩 위임 객체로 옮기고, 슈퍼클래스에서 "위임이 있으면 위임" 보호 코드.
   또는 슈퍼클래스를 위임으로(12.11) ─ 슈퍼클래스 인스턴스를 필드로 갖고 전달 함수를 하나씩.
→ 죽은 코드 제거(8.9) ─ 빈 서브클래스 삭제.
```
- 이유가 분명할 때만: 두 축으로 분류해야 할 때, 서브클래스가 부모 인터페이스를 거부할 때(상속 포기 3.23의 강한 형태), 부모 변경이 자식을 자꾸 깨뜨릴 때.
- 반대 방향(위임 → 상속)이 맞는 경우도 있다: 위임 메서드가 거의 전부 단순 전달이면 중개자(3.18)다.

## R8. 반복문 정리

```
반복문 쪼개기(8.7) ─ 한 반복문이 두 개 이상의 결과를 만들면 결과별로 복제.
→ 문장 슬라이드(8.6) ─ 각 반복문과 그 결과 변수 선언을 붙인다.
→ 함수 추출(6.1) ─ 반복문 하나 = 함수 하나(`totalSalary()`, `youngestAge()`).
→ 반복문을 파이프라인으로(8.8) ─ 각 함수 안에서 filter/map/reduce로.
```
- 성능 걱정으로 쪼개기를 미루지 않는다. 측정해서 병목이면 그때 합친다(2.8).

## R9. 매개변수 목록 정리

```
매개변수를 질의 함수로(11.5) ─ 다른 매개변수나 this에서 얻을 수 있는 값 제거.
→ 플래그 인수 제거(11.3) ─ 불리언 플래그마다 명시적 함수.
→ 객체 통째로 넘기기(11.4) ─ 한 객체에서 꺼낸 값 둘 이상 → 객체 자체.
→ 매개변수 객체(6.8) ─ 항상 같이 다니는 값들 → 값 객체(R5로 발전 가능).
→ 여러 함수를 클래스로(6.9) ─ 여러 함수가 같은 매개변수 묶음을 공유하면.
```

## R10. 오류 처리 정리

```
질의 함수와 변경 함수 분리(11.1) ─ 값을 돌려주면서 실패 신호도 섞는 함수 분리.
→ 오류 코드를 예외로(11.12) ─ 예상 밖의 오류만. 상위에 핸들러부터 만든 뒤 아래에서 던진다.
→ 예외를 사전확인으로(11.13) ─ 호출 전에 검사 가능한 조건은 조건문으로.
→ 어서션 추가(10.6) ─ "항상 참"인 가정을 명시.
```
- Go·Rust처럼 오류 값이 관용인 언어에서는 11.12를 뒤집어 읽는다(`language-notes.md`).

---

## 처음부터 끝까지: 영수증 출력 함수 (R1 → R3 → R2)

원본. 한 함수가 파싱·계산·포맷팅을 다 하고, 고객 등급 분기가 두 군데 반복된다.

```js
function receipt(order, customer) {
  let total = 0, points = 0;
  let out = `영수증 (${customer.name})\n`;
  for (const item of order.items) {
    let price = item.unitPrice * item.qty;
    if (customer.tier === 'gold') price = price * 0.9;
    else if (customer.tier === 'silver') price = price * 0.95;
    out += `  ${item.name} x${item.qty}: ${price.toFixed(0)}원\n`;
    total += price;
    if (customer.tier === 'gold') points += Math.floor(item.qty * 2);
    else if (customer.tier === 'silver') points += item.qty;
    else points += Math.floor(item.qty / 2);
  }
  out += `합계: ${total.toFixed(0)}원\n적립: ${points}점\n`;
  return out;
}
```

**커밋 0 — 안전망.** 골드·실버·일반 고객 각 1건씩 출력 문자열 전체를 고정하는 특성화 테스트 3개. 일부러 `0.9`를 `0.8`로 바꿔 테스트가 빨개지는지 확인 후 되돌림.

**커밋 1 — 함수 추출(6.1): 항목 가격.**
```js
function itemPrice(item, customer) {
  let price = item.unitPrice * item.qty;
  if (customer.tier === 'gold') price = price * 0.9;
  else if (customer.tier === 'silver') price = price * 0.95;
  return price;
}
```
반복문 안은 `const price = itemPrice(item, customer);`로. 테스트 초록.

**커밋 2 — 함수 추출(6.1): 항목 적립 점수.** 같은 방식으로 `itemPoints(item, customer)`. 이제 반복문 본문이 세 줄.

**커밋 3 — 반복문 쪼개기(8.7) → 반복문을 파이프라인으로(8.8).** 합계·적립·출력 줄을 각각 계산.
```js
const lines = order.items.map(i => `  ${i.name} x${i.qty}: ${itemPrice(i, customer).toFixed(0)}원`);
const total = order.items.reduce((s, i) => s + itemPrice(i, customer), 0);
const points = order.items.reduce((s, i) => s + itemPoints(i, customer), 0);
```
`itemPrice`가 두 번 호출되지만 순수 함수이므로 동작은 같다. 성능은 나중 문제.

**커밋 4 — 단계 쪼개기(6.11).** 계산 단계와 렌더링 단계를 중간 자료구조로 분리.
```js
function receipt(order, customer) {
  return renderText(enrichOrder(order, customer));
}
function enrichOrder(order, customer) {
  const items = order.items.map(i => ({ ...i, price: itemPrice(i, customer), points: itemPoints(i, customer) }));
  return {
    customerName: customer.name,
    items,
    total: items.reduce((s, i) => s + i.price, 0),
    points: items.reduce((s, i) => s + i.points, 0),
  };
}
function renderText(data) {
  let out = `영수증 (${data.customerName})\n`;
  for (const i of data.items) out += `  ${i.name} x${i.qty}: ${i.price.toFixed(0)}원\n`;
  out += `합계: ${data.total.toFixed(0)}원\n적립: ${data.points}점\n`;
  return out;
}
```
이 시점에서 HTML 영수증 요청이 오면 `renderHtml(data)`만 추가하면 된다.

**커밋 5 — 생성자를 팩터리 함수로(11.8) + 타입 코드를 서브클래스로(12.6).** `customer.tier` 분기가 `itemPrice`·`itemPoints` 두 곳에 반복된다(반복되는 switch 3.12).
```js
class Pricing { discountRate() { return 1; } pointsFor(qty) { return Math.floor(qty / 2); } }
class GoldPricing extends Pricing { discountRate() { return 0.9; } pointsFor(qty) { return Math.floor(qty * 2); } }
class SilverPricing extends Pricing { discountRate() { return 0.95; } pointsFor(qty) { return qty; } }
function createPricing(tier) {
  return { gold: new GoldPricing(), silver: new SilverPricing() }[tier] ?? new Pricing();
}
```

**커밋 6 — 조건부 로직을 다형성으로(10.4).**
```js
function itemPrice(item, pricing) { return item.unitPrice * item.qty * pricing.discountRate(); }
function itemPoints(item, pricing) { return pricing.pointsFor(item.qty); }
```
`enrichOrder`는 `const pricing = createPricing(customer.tier);`를 만들어 넘긴다. `if/else` 분기 소멸.

**커밋 7 — 이름 재검토·죽은 코드 제거.** `out` 같은 이름을 `text`로, 쓰이지 않게 된 지역 변수 정리. 전체 테스트 초록.

커밋 1~7 중 어느 지점에서 멈춰도 원본보다 낫다. 새 등급(`platinum`)을 추가하려면 이제 클래스 하나와 팩터리 한 줄만 손대면 된다 — 산탄총 수술(3.8)이 사라졌다.
