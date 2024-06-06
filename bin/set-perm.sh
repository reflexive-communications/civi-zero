#!/usr/bin/env bash
##################################################
## civi-zero                                    ##
##                                              ##
## Set file permissions                         ##
##                                              ##
## Options:                                     ##
##   $1 Install dir, where CiviCRM is installed ##
##################################################

# Strict mode
set -eufo pipefail
IFS=$'\n\t'

# Include library
base_dir=$(builtin cd "$(dirname "${0}")/.." >/dev/null 2>&1 && pwd)
# shellcheck source=bin/library.sh
. "${base_dir}/bin/library.sh"

# Include configs
# shellcheck source=cfg/install.cfg
. "${base_dir}/cfg/install.cfg"
# shellcheck disable=SC1091
[[ -r "${base_dir}/cfg/install.local.cfg" ]] && . "${base_dir}/cfg/install.local.cfg"

# Parse options
install_dir="${1:-${base_dir}}"
install_dir=$(realpath "${install_dir}")

print-status Set permissions...
# Base
sudo chown -R "${USER}:www-data" "${install_dir}"
sudo chmod -R u+rw,g+r "${install_dir}"
# Files
sudo chmod -R g+w "${install_dir}/web/sites/default/files"
print-finish

exit 0
