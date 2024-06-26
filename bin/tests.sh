#!/usr/bin/env bash
##################################################
## civi-zero                                    ##
##                                              ##
## Run unit tests                               ##
##                                              ##
## Required options:                            ##
##   $1 Install dir, where CiviCRM is installed ##
##   $2 Extension dir name                      ##
##   $* Extra options to 'phpunit'              ##
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
install_dir="${1?:Install dir missing}"
extension_dir="${2?:Extension dir missing}"
shift 2
install_dir=$(realpath "${install_dir}")
extension_target="${install_dir}/web/extensions"
extension_dir_basename=$(basename "${extension_dir}")

print-header Run unit tests "(${extension_dir_basename})"
sudo chown -R "${USER}" "${install_dir}/web/"
cd "${extension_target}/${extension_dir_basename}"
"${install_dir}/vendor/bin/phpunit" --verbose --coverage-text --colors=always "${@}"
print-finish

exit 0
