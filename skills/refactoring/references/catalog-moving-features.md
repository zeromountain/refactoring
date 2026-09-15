# 8장 기능 이동 (Moving Features)

요소를 다른 컨텍스트(클래스·모듈)로 옮기고, 문장을 함수 안팎으로 옮기고, 반복문을 정리하고, 죽은 코드를 지운다.

---

## 8.1 함수 옮기기 (Move Function)
- 1판 이름: 메서드 옮기기(Move Method)

**배경**
- 모듈성의 핵심은 연관된 요소를 한데 모으는 것. 함수가 **자신이 속한 모듈보다 다른 모듈의 요소를 더 많이 참조**하면(기능 편애 3.9) 옮긴다.
- 호출자가 어디인지, 호출하는 함수가 무엇인지, 어떤 데이터를 쓰는지 보고 목적지를 정한다. 선택이 어려우면 일단 옮겨 보고 더 나빠지면 되돌려도 된다.

**절차**
1. 선택한 함수가 현재 컨텍스트에서 사용하는 모든 요소를 살펴본다. 함께 옮겨야 할 것이 있는지 판단(그렇다면 그것부터 옮기는 게 나을 수도).
2. 선택한 함수가 다형 메서드인지 확인(슈퍼·서브클래스 선언 고려).
3. 함수를 타깃 컨텍스트로 **복사**하고 다듬는다. 새 컨텍스트에서 필요한 것을 매개변수로 받거나 원본 컨텍스트 참조를 넘긴다. 이름도 새 컨텍스트에 맞게.
4. 정적 분석.
5. 원본 컨텍스트에서 타깃 함수를 참조할 방법을 마련한다.
6. 원본 함수를 **위임 함수**로 만든다(타깃 호출만).
7. 테스트.
8. 원본 함수를 인라인(6.2)할지 검토한다. 위임 함수를 남겨 둬도 괜찮으면 남긴다.

**예시**
```js
// before
class Account {
  get overdraftCharge() {
    if (this.type.isPremium) { /* ... daysOverdrawn 사용 */ }
    return this.daysOverdrawn * 1.75;
  }
}
// after: type과 관련된 로직이므로 AccountType으로 이동
class AccountType {
  overdraftCharge(daysOverdrawn) {
    if (this.isPremium) { /* ... */ }
    return daysOverdrawn * 1.75;
  }
}
class Account {
  get overdraftCharge() { return this.type.overdraftCharge(this.daysOverdrawn); }
}
```

---

## 8.2 필드 옮기기 (Move Field)

**배경**
- 자료구조가 잘못돼 있으면 코드가 온통 데이터 이곳저곳을 오간다. 한 레코드를 넘길 때마다 다른 레코드의 필드도 함께 넘겨야 하거나, 한 필드를 바꿀 때마다 다른 레코드의 필드도 바꿔야 하면 옮긴다.
- 함수 옮기기(8.1)보다 어렵다. 필드를 **캡슐화**(6.6)해 두면 훨씬 쉽다.

**절차**
1. 소스 필드가 캡슐화되어 있지 않다면 캡슐화한다.
2. 테스트.
3. 타깃 객체에 필드(와 접근자)를 생성한다.
4. 정적 검사.
5. 소스 객체에서 타깃 객체를 참조할 수 있는지 확인(없으면 참조를 마련하거나, 타깃 인스턴스를 만들거나, 생성자·매개변수로 넘긴다).
6. 소스의 접근자가 타깃 필드를 사용하도록 수정한다(소스는 위임).
7. 테스트.
8. 소스 필드를 제거한다.
9. 테스트.
- 공유 객체로 옮길 때(예: 고객이 참조하는 계약)는 갱신 타이밍과 공유 여부에 주의.

**예시**
```js
// before
class Customer {
  get plan() { return this._plan; }
  get discountRate() { return this._discountRate; }
}
// after: discountRate는 계약(Contract)에 속하는 정보
class Customer {
  get plan() { return this._plan; }
  get discountRate() { return this._contract.discountRate; }
}
```

---

## 8.3 문장을 함수로 옮기기 (Move Statements into Function)
- 반대: 문장을 호출한 곳으로 옮기기(8.4)

**배경**
- 특정 함수를 호출할 때마다 **항상 같은 코드**가 앞뒤에 따라온다면, 그 코드를 함수 안으로 옮겨 중복을 없앤다. 나중에 달라지면 다시 빼면 된다(8.4).
- 옮길 코드가 함수와 **한 몸**이라는 확신이 있을 때. 아니면 새 함수를 추출(6.1)하는 게 낫다.

**절차**
1. 반복되는 코드가 호출 지점과 떨어져 있으면 문장 슬라이드(8.6)로 붙인다.
2. 타깃 함수의 호출자가 하나뿐이면 소스 코드를 잘라 타깃에 붙이고 테스트. 끝.
3. 호출자가 여럿이면 호출자 하나에서 "타깃 함수 호출 + 옮기려는 문장"을 함께 **새 함수로 추출**(6.1)한다. 임시 이름 가능.
4. 다른 호출자들도 새 함수를 쓰게 바꾼다. 매번 테스트.
5. 모두 바꿨으면 원래 타깃 함수를 새 함수 안으로 인라인(6.2)하고 제거한다.
6. 새 함수 이름을 원래 타깃 함수 이름으로 바꾼다(6.5).

**예시**
```js
// before
result.push(`<p>제목: ${person.photo.title}</p>`);
result.concat(photoData(person.photo));
function photoData(aPhoto) { return [`<p>위치: ${aPhoto.location}</p>`, `<p>날짜: ${aPhoto.date}</p>`]; }
// after
result.concat(photoData(person.photo));
function photoData(aPhoto) {
  return [`<p>제목: ${aPhoto.title}</p>`, `<p>위치: ${aPhoto.location}</p>`, `<p>날짜: ${aPhoto.date}</p>`];
}
```

---

## 8.4 문장을 호출한 곳으로 옮기기 (Move Statements to Callers)
- 반대: 문장을 함수로 옮기기(8.3)

**배경**
- 함수 안에 있던 공통 동작이 **일부 호출자에서만** 달라져야 할 때, 달라지는 부분을 함수 밖 호출자 쪽으로 꺼낸다.
- 작은 변경이면 이 기법으로 충분. 함수 경계 자체가 잘못됐다면 인라인(6.2) 후 다시 추출(6.1)한다.

**절차**
1. 호출자가 하나뿐이면 옮길 코드를 잘라 호출자에 붙이고 테스트.
2. 호출자가 여럿이면 옮기지 않을 코드를 **새 함수로 추출**(6.1)한다(임시 이름).
3. 옮길 문장이 함수의 처음이나 끝에 오도록 문장 슬라이드(8.6).
4. 원래 함수를 호출하는 곳마다 인라인(6.2)한 뒤 남는 문장을 정리한다. 매번 테스트.
5. 원래 함수를 제거하고 새 함수 이름을 원래 이름으로 바꾼다(6.5).

**예시**
```js
// before
emitPhotoData(outStream, person.photo);
function emitPhotoData(outStream, photo) {
  outStream.write(`<p>제목: ${photo.title}</p>\n`);
  outStream.write(`<p>위치: ${photo.location}</p>\n`);
}
// after: 위치 출력은 호출자마다 다르게 하고 싶다
emitPhotoData(outStream, person.photo);
outStream.write(`<p>위치: ${person.photo.location}</p>\n`);
function emitPhotoData(outStream, photo) {
  outStream.write(`<p>제목: ${photo.title}</p>\n`);
}
```

---

## 8.5 인라인 코드를 함수 호출로 바꾸기 (Replace Inline Code with Function Call)

**배경**
- 이미 존재하는 함수와 **같은 일**을 하는 인라인 코드가 있으면 함수 호출로 바꾼다. 중복이 사라지고 의도가 이름으로 드러난다.
- 특히 표준 라이브러리(`includes`, `some`, `every` 등)로 대체 가능한 반복문이 흔하다.
- 함수 이름이 인라인 코드의 목적을 설명하지 못하면(우연히 같은 동작) 바꾸지 않는다 — 나중에 따로 진화할 코드다.

**절차**
1. 인라인 코드를 함수 호출로 대체한다.
2. 테스트.

**예시**
```js
// before
let appliesToMass = false;
for (const s of states) if (s === 'MA') appliesToMass = true;
// after
const appliesToMass = states.includes('MA');
```

---

## 8.6 문장 슬라이드하기 (Slide Statements)
- 1판 이름: 조건문의 공통 실행 코드 빼내기(Consolidate Duplicate Conditional Fragments)

**배경**
- 관련된 코드가 **가까이** 모여 있어야 이해하기 쉽다. 변수는 처음 사용하는 곳 바로 앞에서 선언한다.
- 다른 리팩터링(특히 함수 추출 6.1)의 준비 단계로 자주 쓴다. 조건문의 여러 분기에 같은 코드가 있으면 조건문 밖으로 슬라이드해 하나로 합친다.

**절차**
1. 코드 조각을 이동할 목표 위치를 찾는다. 원본과 목표 사이의 문장들을 보고 이동이 **동작을 바꾸지 않는지** 확인한다. 간섭이 있으면 포기.
   - 이동 조각이 참조하는 요소를 선언하는 문장 앞으로는 못 간다.
   - 이동 조각을 참조하는 문장 뒤로는 못 간다.
   - 이동 조각이 수정하는 요소를 참조하는 문장을 건너뛸 수 없다.
   - 이동 조각이 참조하는 요소를 수정하는 문장을 건너뛸 수 없다.
2. 조각을 잘라 목표 위치에 붙인다.
3. 테스트.
- 테스트가 실패하면 더 작은 단계로 나눈다(이동 거리를 줄이거나 조각을 줄인다).
- 부작용 없는 코드(명령-질의 분리가 잘 된 코드)에서 훨씬 쉽다.

**예시**
```js
// before
const pricingPlan = retrievePricingPlan();
const order = retrieveOrder();
let charge;
const chargePerUnit = pricingPlan.unit;
// after
const pricingPlan = retrievePricingPlan();
const chargePerUnit = pricingPlan.unit;
const order = retrieveOrder();
let charge;
```

---

## 8.7 반복문 쪼개기 (Split Loop)

**배경**
- 한 반복문에서 두 가지 일을 하면 수정할 때마다 둘 다 이해해야 한다. 반복문을 나누면 각각을 **따로 추출**(6.1)하고 이름 붙일 수 있다.
- 반복이 두 번 도는 것을 걱정하지 마라. 리팩터링과 최적화는 별개다(2.8). 병목이 되면 그때 합친다.
- 보통 쪼개기 → 각 반복문 함수 추출 → 파이프라인으로 바꾸기(8.8)로 이어진다.

**절차**
1. 반복문을 복제한다.
2. 반복문이 중복돼 생기는 부수효과를 제거한다(각 반복문이 자기 일만 하도록).
3. 테스트.
4. 각 반복문을 함수로 추출(6.1)할지 검토.

**예시**
```js
// before
let averageAge = 0, totalSalary = 0;
for (const p of people) { averageAge += p.age; totalSalary += p.salary; }
averageAge = averageAge / people.length;
// after
let totalSalary = 0;
for (const p of people) totalSalary += p.salary;
let averageAge = 0;
for (const p of people) averageAge += p.age;
averageAge = averageAge / people.length;
// → 이어서 각각 totalSalary(), averageAge() 로 추출하고 reduce 파이프라인으로
```

---

## 8.8 반복문을 파이프라인으로 바꾸기 (Replace Loop with Pipeline)

**배경**
- 컬렉션 파이프라인(`map`, `filter`, `reduce`, `some`, `find` …)은 각 단계가 무엇을 하는지 **위에서 아래로 읽힌다**. 반복문은 어떤 원소가 어떻게 처리되는지 따라가며 추적해야 한다.
- 각 파이프라인 단계는 이전 단계의 결과만 받는 순수 변환이다.

**절차**
1. 반복문에서 사용하는 컬렉션을 가리키는 변수를 만든다.
2. 반복문의 첫 줄부터 각 단위 행위를 적절한 파이프라인 연산으로 대체한다. 파이프라인은 1에서 만든 변수에서 시작. 하나 바꿀 때마다 테스트.
3. 반복문의 모든 동작을 대체했다면 반복문을 지운다. 결과를 누적하던 변수는 파이프라인 결과로 대체.

**예시**
```js
// before
const names = [];
for (const i of input) {
  if (i.job === 'programmer') names.push(i.name);
}
// after
const names = input
  .filter(i => i.job === 'programmer')
  .map(i => i.name);
```

---

## 8.9 죽은 코드 제거하기 (Remove Dead Code)

**배경**
- 쓰이지 않는 코드는 실행 성능에는 영향 없지만 **읽는 사람의 시간**을 잡아먹는다("이게 왜 여기 있지? 언젠가 필요한가?").
- 주석 처리로 남기지 마라. 버전 관리 시스템이 기억한다. 정말 필요하면 커밋 메시지에 남긴다.
- 추측성 일반화(3.15)의 마무리.

**절차**
1. 죽은 코드를 외부에서 참조할 수 있는지(내보내기 등) 확인. 참조하는 곳이 없는지 확인.
2. 죽은 코드를 제거한다.
3. 테스트.

**예시**
```js
// before
if (false) { doSomethingThatUsedToMatter(); }
// after
// (삭제)
```
