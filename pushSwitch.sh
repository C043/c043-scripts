#!/bin/bash

set -o pipefail

tmp_err="$(mktemp)"
trap 'rm -f "$tmp_err"' EXIT

if ! git push --progress 2> >(tee "$tmp_err" >&2); then
	# Switch only for "repo not found" or permission-denied pushes.
	if grep -Eq \
		"remote: Repository not found\.|fatal: repository '.*' not found|remote: Permission to .* denied|ERROR: Permission to .* denied|requested URL returned error: 403" \
		"$tmp_err"; then
		gh auth switch
		git push
	else
		cat "$tmp_err" >&2
		exit 1
	fi
fi
