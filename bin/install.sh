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
routing="127.0.0.1 ${civi_domain}"
doc_root="${install_dir}/web"

print-header "Purge instance..."
sudo mysql -u"${db_user_name}" -p"${db_user_pass}" -e "DROP DATABASE IF EXISTS ${db_name};"
sudo rm -rf "${install_dir}/web/sites/default/civicrm.settings.php" "${install_dir}/web/sites/default/settings.php" "${install_dir}/web/sites/default/files/"
print-finish

print-header "Add Civi vhost..."
# Routing
if ! grep -qs "${routing}" /etc/hosts; then
    echo "${routing}" | sudo tee -a /etc/hosts >/dev/null
fi
# Document root
sudo mkdir -p "${doc_root}"
sudo chgrp -R www-data "${install_dir}"
# Vhost
sudo cp "${install_dir}/vhost.conf" "/etc/apache2/sites-available/${civi_domain}.conf"
sudo sed -i \
    -e "s@{{ site }}@${civi_domain}@g" \
    -e "s@{{ doc_root }}@${doc_root}@g" \
    "/etc/apache2/sites-available/${civi_domain}.conf"
sudo a2ensite "${civi_domain}.conf"
sudo systemctl reload apache2.service
print-finish

# Testing
echo puruttya | sudo tee -a "${doc_root}/majom" >/dev/null
sudo chgrp -R www-data "${doc_root}/majom"
ls -lah "${install_dir}"
ls -lah "${install_dir}/web"
curl "http://${civi_domain}/majom"

exit 0
