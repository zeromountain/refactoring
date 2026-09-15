export function printInvoice(raw: string, customers: Record<string, any>) {
  const parts = raw.split('|');
  const cid = parts[0]; const lines = parts.slice(1);
  const c = customers[cid];
  let total = 0; let disc = 0; let out = '';
  for (const l of lines) {
    const [sku, q, p] = l.split(',');
    let amt = Number(q) * Number(p);
    if (c.type === 'vip') disc += amt * 0.2;
    else if (c.type === 'member') disc += amt * 0.1;
    total += amt;
    out += sku + ' ' + q + ' ' + amt + '\n';
  }
  let fee = 0;
  if (c.type === 'vip') fee = 0;
  else if (c.type === 'member') fee = total > 50000 ? 0 : 2500;
  else fee = 3000;
  out += 'total ' + (total - disc + fee) + '\n';
  if (c.type === 'vip') out += 'VIP thanks\n';
  return out;
}
