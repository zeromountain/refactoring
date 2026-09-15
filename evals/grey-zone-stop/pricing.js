/**
 * 공개 API. @acme/checkout 과 @acme/reports 가 호출한다 — README.md 참고.
 */
function total(items, includeTax) {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  return includeTax ? subtotal * 1.1 : subtotal;
}

module.exports = { total };
