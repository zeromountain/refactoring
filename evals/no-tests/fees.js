function shippingFee(weightKg, region, member) {
  let fee;
  if (region === 'domestic') fee = weightKg <= 1 ? 3000 : 3000 + Math.ceil(weightKg - 1) * 500;
  else if (region === 'asia') fee = 8000 + Math.ceil(weightKg) * 1500;
  else fee = 15000 + Math.ceil(weightKg) * 3000;
  if (member) fee = fee * 0.9;
  if (weightKg > 30) fee = fee + 10000;
  return Math.round(fee);
}

module.exports = { shippingFee };
