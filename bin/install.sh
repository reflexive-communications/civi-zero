#!/usr/bin/env bash
#####################
## civi-zero       ##
##                 ##
## Install CiviCRM ##
#####################

#################
## SCRIPT START #
#################

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
db_user_name="${2?:'DB user name missing'}"
db_user_pass="${3?:'DB user pass missing'}"
db_name="${4?:'DB name missing'}"

print-header "Purge instance..."
sudo mysql -u"${db_user_name}" -p"${db_user_pass}" -e "DROP DATABASE IF EXISTS ${db_name};"
sudo rm -rf "${install_dir}/web/sites/default/civicrm.settings.php" "${install_dir}/web/sites/default/settings.php" "${install_dir}/web/sites/default/files/"
print-finish

pwd
ls -lah "${install_dir}"

exit 0
