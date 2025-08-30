#!/usr/bin/env bash
set -euo pipefail

cmd=${1:-}
key_id=${2:-}
issuer_id=${3:-}
ipa_path=${4:-}

project_root_dir=$(cd "$(dirname "$0")/.." && pwd)
keys_dir="$project_root_dir/private_keys"
key_file="$keys_dir/AuthKey_${key_id}.p8"

err() { echo "[error] $*" >&2; }
info() { echo "[info] $*"; }

require_key() {
  if [[ ! -f "$key_file" ]]; then
    err "Missing key file: $key_file"
    err "Place your App Store Connect key as: $key_file"
    err "File name must be exactly: AuthKey_${key_id}.p8"
    exit 1
  fi
  # Tighten permissions (altool doesn't require, but good hygiene)
  chmod 600 "$key_file" || true
}

case "$cmd" in
  verify)
    if [[ -z "$key_id" || -z "$issuer_id" ]]; then
      err "Usage: $0 verify <KEY_ID> <ISSUER_ID>"; exit 2; fi
    require_key
    info "Verifying App Store Connect authentication..."
    set -x
    xcrun altool --list-providers --apiKey "$key_id" --apiIssuer "$issuer_id"
    ;;
  upload)
    if [[ -z "$key_id" || -z "$issuer_id" || -z "$ipa_path" ]]; then
      err "Usage: $0 upload <KEY_ID> <ISSUER_ID> <IPA_PATH>"; exit 2; fi
    require_key
    if [[ ! -f "$ipa_path" ]]; then
      err "IPA not found: $ipa_path"; exit 3; fi
    info "Uploading IPA to App Store Connect..."
    set -x
    xcrun altool --upload-app --type ios -f "$ipa_path" --apiKey "$key_id" --apiIssuer "$issuer_id"
    ;;
  *)
    err "Usage: $0 <verify|upload> <KEY_ID> <ISSUER_ID> [IPA_PATH]"; exit 2;
    ;;
esac

