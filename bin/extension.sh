#!/usr/bin/env bash
####################################################
## civi-zero                                      ##
##                                                ##
## Install extension                              ##
##                                                ##
## Required options:                              ##
##   $1 Install dir, where CiviCRM is installed   ##
##   $2 Extension path                            ##
##   $3 Extension key                             ##
##      If key same as dir name then not required ##
####################################################

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
[[ -r "${base_dir}/cfg/install.local" ]] && . "${base_dir}/cfg/install.local"

# Parse options
install_dir="${1?:"Install dir missing"}"
extension_dir="${2?:"Extension dir missing"}"
extension_key="${3:-}"
install_dir=$(realpath "${install_dir}")
extension_target="${install_dir}/web/extensions"

# Extension key not supplied --> it is the same as the dir
[[ -z "${extension_key}" ]] && extension_key=$(basename "${extension_dir}")

print-status "Copy extension to CiviCRM (${extension_key})..."
cp -a "${extension_dir}" "${extension_target}/"
print-finish

if [[ -f "${extension_target}/${extension_dir}/composer.json" ]]; then
    print-header "Run composer install..."
    composer install --no-interaction --working-dir="${extension_target}/${extension_dir}"
    print-finish
fi

print-status "Set permissions..."
sudo chgrp -R www-data "${extension_target}/${extension_dir}"
print-finish

print-header "Enable extension (${extension_key})..."
sudo -u www-data cv ext:enable \
    --no-interaction \
    --cwd="${install_dir}" \
    --user="${civi_user}" \
    -- "${extension_key}"
print-finish

exit 0
