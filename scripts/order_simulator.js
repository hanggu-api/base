#!/usr/bin/env node
const { insert, parseArgs } = require('./supabase_client');

const CUSTOMER_ID = '00000000-0000-4000-8000-000000000001';
const RESTAURANT_ID = '10000000-0000-4000-8000-000000000001';
const ADDRESS_ID = '30000000-0000-4000-8000-000000000001';
const COURIER_ID = '00000000-0000-4000-8000-000000000003';

function uuidFromCounter(prefix, counter) {
  return `${prefix}-0000-4000-8000-${String(counter).padStart(12, '0')}`;
}

async function main() {
  const args = parseArgs(process.argv);
  const count = Number.parseInt(args.orders || '5', 10);
  const statuses = ['placed', 'accepted', 'preparing', 'ready_for_pickup', 'picked_up'];

  for (let index = 0; index < count; index += 1) {
    const subtotal = 2490 + (index % 5) * 700;
    const order = {
      id: uuidFromCounter('50000000', index + 1),
      customer_id: CUSTOMER_ID,
      restaurant_id: RESTAURANT_ID,
      courier_id: index % 2 === 0 ? COURIER_ID : null,
      address_id: ADDRESS_ID,
      status: statuses[index % statuses.length],
      subtotal_cents: subtotal,
      delivery_fee_cents: 690,
      payment_status: index % 3 === 0 ? 'authorized' : 'captured',
      notes: `Pedido simulado #${index + 1}`,
    };
    await insert('orders', order, args.dryRun);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
