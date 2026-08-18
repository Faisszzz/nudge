#!/bin/zsh

set -euo pipefail

logo_dir="/Library/Application Support/ITQ/Nudge"
logo_path="${logo_dir}/nudge-logo-itq.png"
logo_url="https://companybrandingmsp.blob.core.windows.net/branding/ITQ/Nudge-Logo-ITQ.png"

mkdir -p "$logo_dir"

/usr/bin/curl --fail --location --silent --show-error "$logo_url" --output "$logo_path"

/usr/sbin/chown root:wheel "$logo_path"
/bin/chmod 644 "$logo_path"

if [[ ! -s "$logo_path" ]]; then
  echo "Logo download failed or produced an empty file: $logo_path"
  exit 1
fi

echo "Nudge logo installed at: $logo_path"
