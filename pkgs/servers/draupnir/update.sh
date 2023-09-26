#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl common-updater-scripts nix coreutils jq

set -euo pipefail

echo "Getting versions..."
latestVersion="$(curl -sL "https://api.github.com/repos/the-draupnir-project/Draupnir/releases?per_page=1" | jq -r '.[0].tag_name | ltrimstr("v")')"
echo " --> Latest version: ${latestVersion}"
currentVersion=$(nix-instantiate --eval -E "with import ./. {}; draupnir.version or (lib.getVersion draupnir)" | tr -d '"')
echo " --> Current version: ${currentVersion}"
if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "Draupnir is up-to-date: $currentVersion"
  exit 0
else
  echo "We are out of date..."
fi

update-source-version draupnir "$latestVersion"
sed -i 's/hash = "sha256.*/hash = "'`nix-hash --type sha256 --flat --base32 --sri <(curl https://raw.githubusercontent.com/the-draupnir-project/Draupnir/HEAD/yarn.lock)`'";/' pkgs/servers/draupnir/default.nix
