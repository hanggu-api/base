const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

function parseArgs(argv) {
  const args = { dryRun: false };
  for (let index = 2; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--dry-run') {
      args.dryRun = true;
    } else if (value.startsWith('--')) {
      args[value.slice(2)] = argv[index + 1];
      index += 1;
    }
  }
  return args;
}

async function insert(table, payload, dryRun) {
  if (dryRun) {
    console.log(JSON.stringify({ table, payload }, null, 2));
    return payload;
  }

  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY or use --dry-run.');
  }

  const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}`, {
    method: 'POST',
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      'content-type': 'application/json',
      prefer: 'return=representation',
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    throw new Error(`${table} insert failed: ${response.status} ${await response.text()}`);
  }

  return response.json();
}

module.exports = { insert, parseArgs };
