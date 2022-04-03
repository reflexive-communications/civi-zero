#!/usr/bin/env bash
#######################
## civi-zero         ##
##                   ##
## Install extension ##
#######################

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Include library
base_dir="$(builtin cd "$(dirname "${0}")" >/dev/null 2>&1 && pwd)"
. "${base_dir}/library.sh"

# Include configs
. "${base_dir}/../install.conf"
[[ -r "${base_dir}/../install.local" ]] && . "${base_dir}/../install.local"

# Parse options
install_dir="${1?:'Install dir missing'}"
extension_dir="${2?:'Extension dir missing'}"
extension_key="${3:-}"
extension_target="${install_dir}/web/extensions"

# Extension key not supplied --> it is the same as the dir
[[ -z "${extension_key}" ]] && extension_key=$(basename "${extension_dir}")

print-header "Move extension to CiviCRM (${extension_key})"
mv "${extension_dir}" "${extension_target}/"
sudo chgrp -R www-data "${extension_target}/${extension_dir}"
print-finish

ls -lah "${extension_target}/"

exit 0
