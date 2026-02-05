#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# CONFIG
# ==========================================================
BACKUP_HOST="100.66.151.63" # Tailscale hostname
BACKUP_USER="c043"
REPO_BASE="/media/c043/Drive/borg"

HOST="$(hostname -s)"
REPO="ssh://${BACKUP_USER}@${BACKUP_HOST}${REPO_BASE}/${HOST}"
ARCHIVE="${HOST}-$(date +%F-%H%M)"

BASE_HOME="/home/c043"
BACKUPS_DIR="/var/backups"
PKG_DIR="${BACKUPS_DIR}/packages"
DB_DIR="${BACKUPS_DIR}/db"

echo "▶ Backup started: $(date -Is)"
echo "▶ Repo: $REPO"
echo "▶ Archive: $ARCHIVE"

# ==========================================================
# PRE-FLIGHT
# ==========================================================
command -v borg >/dev/null
command -v docker >/dev/null

mkdir -p "$PKG_DIR" "$DB_DIR"
chmod 700 "$BACKUPS_DIR" "$PKG_DIR" "$DB_DIR"

# ==========================================================
# 1) PACKAGE LISTS
# ==========================================================
echo "• Saving package lists"
dpkg --get-selections >"$PKG_DIR/packages.list"
apt-mark showmanual >"$PKG_DIR/packages.manual"
chmod 600 "$PKG_DIR/"*

# ==========================================================
# 2) POSTGRES LOGICAL DUMPS (ONLINE)
# ==========================================================
echo "• Dumping Postgres databases (if any)"
mapfile -t PG_CONTAINERS < <(docker ps -q --filter ancestor=postgres || true)

if [[ "${#PG_CONTAINERS[@]}" -eq 0 ]]; then
	echo "  (no postgres containers found)"
else
	for cid in "${PG_CONTAINERS[@]}"; do
		name="$(docker inspect "$cid" --format '{{.Name}}' | sed 's#^/##')"
		user="$(docker exec "$cid" sh -lc 'echo ${POSTGRES_USER:-postgres}' 2>/dev/null || echo postgres)"
		pass="$(docker exec "$cid" sh -lc 'echo ${POSTGRES_PASSWORD:-}' 2>/dev/null || true)"

		out="${DB_DIR}/${name}_pg_dumpall.sql"
		echo "  - $name → $out"

		if [[ -n "$pass" ]]; then
			docker exec "$cid" sh -lc "PGPASSWORD='$pass' pg_dumpall -U '$user'" >"$out"
		else
			docker exec "$cid" sh -lc "pg_dumpall -U '$user'" >"$out"
		fi

		chmod 600 "$out"
	done
fi

# ==========================================================
# 3) COLLECT ALL DOCKER BIND MOUNTS (AUTO)
# ==========================================================
echo "• Discovering Docker bind mounts"

declare -A BIND_PATHS=()

while IFS= read -r src; do
	# Skip docker.sock
	[[ "$src" == "/var/run/docker.sock" ]] && continue

	# Exclude Jellyfin media
	[[ "$src" == /mnt/ssd/jellyfin* ]] && continue

	# Only real paths
	[[ -e "$src" ]] || continue

	BIND_PATHS["$src"]=1
done < <(
	docker ps -aq | xargs -r docker inspect \
		--format '{{range .Mounts}}{{if eq .Type "bind"}}{{.Source}}{{"\n"}}{{end}}{{end}}'
)

# ==========================================================
# 4) BUILD INCLUDE LIST
# ==========================================================
INCLUDES=(
	/etc
	/root
	/usr/local
	/opt
	/var/spool/cron
	/var/lib/docker/volumes
	"$BACKUPS_DIR"
	"$BASE_HOME"
)

for p in "${!BIND_PATHS[@]}"; do
	INCLUDES+=("$p")
done

# ==========================================================
# 5) EXCLUDES
# ==========================================================
EXCLUDES=(
	/proc
	/sys
	/dev
	/run
	/tmp
	/mnt/ssd/jellyfin
)

EXCLUDE_FLAGS=()
for e in "${EXCLUDES[@]}"; do
	EXCLUDE_FLAGS+=(--exclude "$e")
done

# ==========================================================
# 6) BORG BACKUP
# ==========================================================
echo "• Running Borg backup"
borg create \
	--stats \
	--compression zstd \
	"${EXCLUDE_FLAGS[@]}" \
	"${REPO}::${ARCHIVE}" \
	"${INCLUDES[@]}"

# ==========================================================
# 7) RETENTION
# ==========================================================
echo "• Pruning old backups"
borg prune -v "$REPO" \
	--keep-daily=7 \
	--keep-weekly=4 \
	--keep-monthly=6

echo "✅ Backup completed successfully: $(date -Is)"
