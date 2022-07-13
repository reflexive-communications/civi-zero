#!/usr/bin/env bash
####################
## civi-zero      ##
##                ##
## Run unit tests ##
####################

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Include library
base_dir="$(builtin cd "$(dirname "${0}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=bin/library.sh
. "${base_dir}/library.sh"

# Include configs
# shellcheck source=cfg/install.cfg
. "${base_dir}/../cfg/install.cfg"
# shellcheck disable=SC1091
[[ -r "${base_dir}/../cfg/install.local" ]] && . "${base_dir}/../cfg/install.local"

# Parse options
install_dir="${1?:"Install dir missing"}"
extension="${2?:"Extension missing"}"
extension_target="${install_dir}/web/extensions"

print-header "Run unit tests (${extension})"
sudo chown -R "${USER}" "${install_dir}/web/"
cd "${extension_target}/${extension}"
"${install_dir}/vendor/bin/phpunit" --verbose --coverage-text --colors=always
print-finish

exit 0
