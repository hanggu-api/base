#!/usr/bin/env node
const { insert, parseArgs } = require('./supabase_client');

const DEFAULT_COURIER_ID = '00000000-0000-4000-8000-000000000003';
const DEFAULT_ORDER_ID = '40000000-0000-4000-8000-000000000002';

function point(longitude, latitude) {
  return `SRID=4326;POINT(${longitude} ${latitude})`;
}

async function main() {
  const args = parseArgs(process.argv);
  const steps = Number.parseInt(args.steps || '8', 10);
  const courierId = args.courier || DEFAULT_COURIER_ID;
  const orderId = args.order || DEFAULT_ORDER_ID;
  let latitude = -23.5617;
  let longitude = -46.6559;

  for (let index = 0; index < steps; index += 1) {
    latitude += 0.00035;
    longitude += 0.00028;
    const location = {
      courier_id: courierId,
      order_id: orderId,
      location: point(longitude, latitude),
      speed_kmh: Number((28 + Math.sin(index) * 6).toFixed(2)),
      battery_percent: 86 - index,
      recorded_at: new Date(Date.now() + index * 30000).toISOString(),
    };
    await insert('courier_locations', location, args.dryRun);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
