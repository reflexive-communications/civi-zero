#!/usr/bin/env bash
##################################################
## civi-zero                                    ##
##                                              ##
## Init test DB                                 ##
##                                              ##
## Required options:                            ##
##   $1 Install dir, where CiviCRM is installed ##
##################################################

# Strict mode
set -euo pipefail
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

print-status "Purge Civi Test DB..."
sudo mysql -e "DROP DATABASE IF EXISTS ${civi_db_test}"
sudo mysql -e "CREATE DATABASE IF NOT EXISTS ${civi_db_test} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"
print-finish

print-status "Add Civi DB user..."
sudo mysql -e "CREATE USER IF NOT EXISTS ${civi_db_user_name}@localhost IDENTIFIED BY '${civi_db_user_pass}'"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${civi_db_test}.* TO '${civi_db_user_name}'@'localhost'"
sudo mysql -e "GRANT SUPER ON *.* TO '${civi_db_user_name}'@'localhost'"
sudo mysql -e "FLUSH PRIVILEGES"
print-finish

print-header "Init CiviCRM test DataBase..."
sudo -u www-data cv core:install \
    --no-interaction \
    --cwd="${install_dir}" \
    --cms-base-url="https://${civi_domain}" \
    --db="mysql://${civi_db_user_name}:${civi_db_user_pass}@localhost:3306/${civi_db_test}?new_link=true" \
    --comp="${civi_components}" \
    --keep --test
sed -i \
    -e "/CIVICRM_UF === 'UnitTests'/ s/ && isset(\$GLOBALS\['_CV'\]\['TEST_DB_DSN'\])//" \
    -e "/define('CIVICRM_DSN'/ s|\$GLOBALS\['_CV'\]\['TEST_DB_DSN'\]|'mysql://${civi_db_user_name}:${civi_db_user_pass}@localhost:3306/${civi_db_test}?new_link=true'|" \
    "${install_dir}/web/sites/default/civicrm.settings.php"
print-finish

exit 0
