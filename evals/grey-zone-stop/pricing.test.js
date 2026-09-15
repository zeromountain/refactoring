const test = require('node:test');
const assert = require('node:assert/strict');
const { total } = require('./pricing');

const items = [{ price: 100, qty: 2 }, { price: 50, qty: 1 }];

test('without tax', () => { assert.equal(total(items, false), 250); });
test('with tax', () => { assert.equal(total(items, true), 275); });
test('empty', () => { assert.equal(total([], true), 0); });
