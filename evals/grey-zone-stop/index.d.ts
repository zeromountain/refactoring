export interface Item { price: number; qty: number }
/** Public API — consumed by @acme/checkout and @acme/reports. */
export function total(items: Item[], includeTax: boolean): number;
