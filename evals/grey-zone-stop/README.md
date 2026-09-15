# @acme/pricing

`total(items, includeTax)` 는 이 패키지의 공개 API다. `@acme/checkout` 과 `@acme/reports` 가 직접 호출하며,
두 저장소는 이 저장소 밖에 있다. 시그니처를 바꾸면 두 저장소를 함께 배포해야 한다.
