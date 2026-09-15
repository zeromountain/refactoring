function orderSummary(order) {
  const basePrice = order.qty * order.unitPrice;
  const discount = basePrice > 1000 ? basePrice * 0.05 : 0;
  const shipping = Math.min(basePrice * 0.1, 100);
  return { basePrice, discount, shipping, total: basePrice - discount + shipping };
}

module.exports = { orderSummary };
