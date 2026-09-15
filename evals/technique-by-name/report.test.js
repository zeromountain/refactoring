const test = require('node:test');
const assert = require('node:assert/strict');
const { orderSummary } = require('./report');

test('small order: no discount, proportional shipping', () => {
  assert.deepEqual(orderSummary({ qty: 2, unitPrice: 100 }),
    { basePrice: 200, discount: 0, shipping: 20, total: 220 });
});

test('large order: 5% discount, shipping capped at 100', () => {
  assert.deepEqual(orderSummary({ qty: 10, unitPrice: 500 }),
    { basePrice: 5000, discount: 250, shipping: 100, total: 4850 });
});

test('boundary: exactly 1000 gets no discount', () => {
  assert.deepEqual(orderSummary({ qty: 1, unitPrice: 1000 }),
    { basePrice: 1000, discount: 0, shipping: 100, total: 1100 });
});

test('zero quantity', () => {
  assert.deepEqual(orderSummary({ qty: 0, unitPrice: 999 }),
    { basePrice: 0, discount: 0, shipping: 0, total: 0 });
});
