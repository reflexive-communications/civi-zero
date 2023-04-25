#!/usr/bin/env bash
##################################################
## civi-zero                                    ##
##                                              ##
## Clear cache (Drupal + Civi)                  ##
##                                              ##
## Options:                                     ##
##   $1 Install dir, where CiviCRM is installed ##
##################################################

# Strict mode
set -eufo pipefail
IFS=$'\n\t'

# Include library
base_dir="$(builtin cd "$(dirname "${0}")/.." >/dev/null 2>&1 && pwd)"
# shellcheck source=bin/library.sh
. "${base_dir}/bin/library.sh"

# Include configs
# shellcheck source=cfg/install.cfg
. "${base_dir}/cfg/install.cfg"
# shellcheck disable=SC1091
[[ -r "${base_dir}/cfg/install.local" ]] && . "${base_dir}/cfg/install.local"

# Parse options
install_dir="${1:-${base_dir}}"
install_dir=$(realpath "${install_dir}")

print-header "Clear Drupal cache..."
sudo -u www-data "${install_dir}/vendor/bin/drush" cache:rebuild --root "${install_dir}"
print-finish

print-header "Clear Civi cache..."
sudo -u www-data cv flush --cwd="${install_dir}"
print-finish

exit 0
