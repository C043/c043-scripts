// export.js
const fs = require('fs');
const os = require('os');
const path = require('path');
process.loadEnvFile(path.join(__dirname, '.env'));
const api = require('@actual-app/api');

const base = process.env.ACTUAL_BACKUP_DIR
    ? path.resolve(process.env.ACTUAL_BACKUP_DIR)
    : path.join(os.homedir(), 'data');
const dataDir = path.join(base, 'cache');
const outDir = path.join(base, 'backups');

async function main() {
  fs.mkdirSync(dataDir, { recursive: true });
  fs.mkdirSync(outDir, { recursive: true });

  await api.init({
    dataDir,
    serverURL: process.env.ACTUAL_SERVER_URL,
    password: process.env.ACTUAL_PASSWORD,
  });

  try {
    await api.downloadBudget(process.env.ACTUAL_SYNC_ID);

    const data = await api.exportBudget();
    const stamp = new Date().toISOString().slice(0, 10);

    const outFile = path.join(outDir, `actual-${stamp}.zip`);

    fs.writeFileSync(outFile, data);
    console.log(`Exported ${data.length} bytes to ${outFile}`);

    // Keep only the newest KEEP backups (date-stamped names sort chronologically)
    const keep = Number(process.env.ACTUAL_BACKUP_KEEP) || 10;
    const old = fs.readdirSync(outDir)
      .filter(f => /^actual-\d{4}-\d{2}-\d{2}\.zip$/.test(f))
      .sort()
      .slice(0, -keep);
    for (const f of old) {
      fs.unlinkSync(path.join(outDir, f));
      console.log(`Deleted old backup ${f}`);
    }
  } finally {
    await api.shutdown();
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
