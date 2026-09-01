# actual-export

Automated daily backup of a self-hosted [Actual Budget](https://actualbudget.org)
instance. Produces the exact same `.zip` you get from **Settings → Export**, on a
cron schedule, and copies it off-box to a second machine over SSH.

Actual's sync server has no export endpoint — the zip is built client-side — so a
plain `curl` cannot fetch it. This script drives `@actual-app/api`, which runs the
same code path the UI does.

## How it works

1. `api.init()` authenticates against the sync server.
2. `api.downloadBudget()` pulls the budget into a local working copy (`cache/`)
   and syncs it up to date.
3. `api.exportBudget()` returns the zip bytes (`db.sqlite` + `metadata.json`).
4. The zip is written to `backups/actual-YYYY-MM-DD.zip`.
5. cron then `rsync`s the backups directory to a second host.

The zip is a full snapshot, not a delta — it is self-contained and can be
re-imported from the Actual UI via **Import → Actual**.

## Requirements

- Node.js >= 22
- A running Actual sync server
- `rsync` on **both** the local machine and the backup host (see fallback below)

## Install

```bash
cd c043-scripts/actual-export
npm install
```

## Configuration

Copy the template and fill it in. The script loads the file itself via
`process.loadEnvFile()`, so no `source` or wrapper is needed.

```bash
cp .env.example .env
chmod 600 .env
```

| Variable | Required | Meaning |
| --- | --- | --- |
| `ACTUAL_SERVER_URL` | yes | Sync server URL, including protocol and port, no trailing slash |
| `ACTUAL_PASSWORD` | yes | Sync server login password |
| `ACTUAL_SYNC_ID` | yes | Budget sync ID — Actual UI, **Settings → Advanced settings → Sync ID** |
| `ACTUAL_BACKUP_DIR` | no | Base directory for `cache/` and `backups/`. Defaults to `~/data` |

Notes:

- **No `export ` prefix.** Node's `.env` parser wants plain `KEY=value`; with
  `export ` the key literally becomes `export ACTUAL_SERVER_URL`.
- The file holds your server password in plaintext. Keep it at `600`, and never
  commit it — add `.env` to `.gitignore`.

### Directory layout

```
$ACTUAL_BACKUP_DIR/
├── cache/      # working copy of the budget (sqlite), reused between runs
└── backups/    # the actual backups: actual-YYYY-MM-DD.zip
```

`cache/` is disposable — delete it and the next run re-downloads the budget.

## Usage

```bash
node export.js
```

Output:

```
Exported 379135 bytes to /home/youruser/actual-backup/backups/actual-2026-09-01.zip
```

One file per day. Re-running on the same day overwrites that day's zip.

### Reading the log output

`Syncing since <timestamp> 0` and `Got messages from server 0` are normal. Actual
syncs with CRDT messages, not full transfers: the trailing number is how many
changes were exchanged, and `0` means both sides are already in agreement — the
merkle-tree comparison confirms the whole history matches, not just recent rows.

## Off-site copy over SSH

Backups that only exist on the machine being backed up are not backups. Create a
dedicated key with no passphrase (cron cannot answer a prompt):

```bash
ssh-keygen -t ed25519 -f ~/.ssh/actual-backup -N '' -C 'actual-backup'
ssh-keyscan -H backuphost >> ~/.ssh/known_hosts
```

Install the public key on the backup host:

```bash
ssh user@backuphost 'umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys' < ~/.ssh/actual-backup.pub
```

`ssh-copy-id` also works, but it opens a second session to inspect existing keys
and can hang on some setups; the command above is deterministic.

Verify the key works on its own — `IdentitiesOnly=yes` stops SSH from silently
falling back to another key in your agent and giving a false positive:

```bash
ssh -i ~/.ssh/actual-backup -o IdentitiesOnly=yes user@backuphost 'mkdir -p ~/actual-backups && echo ok'
```

### Restricting the key

As created, that key grants a full shell on the backup host. On **backuphost**,
prefix its line in `~/.ssh/authorized_keys`:

```
restrict,command="rsync --server -logDtpre.iLsfxCIvu . actual-backups/" ssh-ed25519 AAAA...
```

`restrict` disables port forwarding, agent forwarding and PTY allocation. The
forced command limits the key to that one rsync invocation. If the exact rsync
option string gives you trouble, start with `restrict` alone — it already covers
most of the risk.

### Transfer

```bash
rsync -a -e "ssh -i $HOME/.ssh/actual-backup -o IdentitiesOnly=yes" \
  $HOME/actual-backup/backups/ user@backuphost:actual-backups/
```

The trailing slash on the source matters: with it, the *contents* are copied;
without it, the directory itself is nested inside the destination.

**No rsync on the backup host?** `command not found: rsync` in the output comes
from the *remote* shell. Either install it there, or point at it explicitly if it
is outside the non-interactive `PATH`:

```bash
rsync -a --rsync-path=/full/path/to/rsync -e "ssh ..." ...
```

As a last resort, `scp` needs nothing on the far side beyond sshd, but it only
copies the file you name — if the backup host was down for three days, those
three zips never arrive. rsync catches up on its own.

```bash
scp -i ~/.ssh/actual-backup -o IdentitiesOnly=yes \
  ~/actual-backup/backups/actual-$(date +%F).zip user@backuphost:actual-backups/
```

## Scheduling

```bash
crontab -e
```

```
0 3 * * * cd $HOME/c043-scripts/actual-export && $HOME/.local/bin/node export.js > $HOME/c043-scripts/actual-export/export.log 2>&1 && /usr/bin/rsync -a -e "ssh -i $HOME/.ssh/actual-backup -o IdentitiesOnly=yes" $HOME/actual-backup/backups/ user@backuphost:actual-backups/ >> $HOME/c043-scripts/actual-export/export.log 2>&1
```

- `0 3 * * *` — 03:00 daily, in the system's local timezone (check `timedatectl`).
- Absolute paths everywhere: cron's `PATH` is minimal and will not find `node`.
- `&&` between the two halves: the upload only runs if the export succeeded.
- First redirect is `>` (truncate), second is `>>` (append), so the log holds only
  the most recent run.
- `%` is special in crontab and must be escaped as `\%` — this is why the `scp`
  variant above needs `actual-$(date +\%F).zip` when used there.

### nvm users

`which node` under nvm returns a version-pinned path that breaks on every
upgrade, and cron fails silently. Point cron at a stable symlink instead:

```bash
mkdir -p ~/.local/bin
ln -sf ~/.nvm/versions/node/v24.12.0/bin/node ~/.local/bin/node
```

The node binary works standalone; it does not need nvm to be sourced.
**Re-run this after every nvm upgrade.**

### Testing before you trust it

Run the exact command with a stripped environment — this is what catches missing
absolute paths and variables you only have interactively:

```bash
env -i HOME=$HOME PATH=/usr/bin:/bin /bin/sh -c 'cd $HOME/c043-scripts/actual-export && $HOME/.local/bin/node export.js && rsync -a -e "ssh -i $HOME/.ssh/actual-backup -o IdentitiesOnly=yes" $HOME/actual-backup/backups/ user@backuphost:actual-backups/'
```

Then confirm the file actually landed, and matches:

```bash
md5sum ~/actual-backup/backups/actual-$(date +%F).zip
ssh user@backuphost "md5sum actual-backups/actual-$(date +%F).zip"
```

To watch the schedule itself, temporarily set the first two fields to `* *`
(every minute), confirm two runs, then put `0 3` back. Do not leave it there:
overlapping runs share `cache/db.sqlite`.

## Verifying a backup

A backup you have never restored is an assumption. Verify one by hand, without
touching your live data.

Pull a zip from the backup host and check it is a well-formed archive:

```bash
scp user@backuphost:actual-backups/actual-2026-09-01.zip /tmp/
unzip -l /tmp/actual-2026-09-01.zip
```

It should list `db.sqlite` and `metadata.json`. A quick read-only look at the
database itself:

```bash
mkdir -p /tmp/actual-check && unzip -o /tmp/actual-2026-09-01.zip -d /tmp/actual-check
sqlite3 -readonly /tmp/actual-check/db.sqlite \
  'select (select count(*) from accounts), (select count(*) from transactions);'
```

For a full check, import it into a **throwaway** Actual instance: open the app in
a private window, choose *Don't use a server*, then **Import → Actual** and load
the zip. Everything stays in that browser profile, with no contact with your sync
server. Compare accounts, categories and month range against your real budget.

Do not test a restore from your server-connected instance. Importing there can
upload the result and leaves you reconciling two budgets.

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| `Could not get remote files` (`network-failure`) | `ACTUAL_SERVER_URL` or `ACTUAL_PASSWORD` missing/wrong. With no password, `init()` skips sign-in entirely and no token is ever issued |
| `ENOENT ... scandir '<dataDir>'` | The data directory does not exist; the script creates it, so this means `ACTUAL_BACKUP_DIR` points somewhere unwritable |
| `EACCES: permission denied, mkdir` | `ACTUAL_BACKUP_DIR` is under a root-owned path such as `/opt`. Use a directory you own |
| `Budget "<id>" not found` | Wrong `ACTUAL_SYNC_ID`. Copy it from Settings → Advanced settings |
| `node: not found` in cron | `PATH` is minimal under cron. Use an absolute path (see nvm note) |
| `command not found: rsync` in the transfer | rsync missing on the *remote* host, or outside its non-interactive `PATH` |
| Cron never fires | The daemon is not running: `systemctl status cronie` (Arch) or `cron` (Debian) |

## Maintenance

- **Retention.** Backups accumulate at roughly 370 KB/day (~135 MB/year) on both
  machines. Once the schedule has proven stable, append to the cron line:

  ```bash
  find $HOME/actual-backup/backups -name '*.zip' -mtime +90 -delete
  ```

- **After an nvm upgrade**, re-create the `~/.local/bin/node` symlink.
- **Failure notification.** A silently broken cron job is worse than none. Wire the
  exit status to ntfy, mail, or a healthcheck ping.

## Security

- The zip is your complete budget in cleartext. Treat every copy accordingly, and
  encrypt it (e.g. `rclone crypt`, `age`) before putting it on third-party storage.
- `.env` holds the sync server password. Keep it at `600` and out of git.
- Use a long passphrase on the sync server itself — it exposes the entire budget to
  anyone who can reach it, private network or not.
