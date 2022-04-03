#!/usr/bin/env bash
#####################
## civi-zero       ##
##                 ##
## Install CiviCRM ##
#####################

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
mysql -u"${db_user_name}" -p"${db_user_pass}" --silent -e "DROP DATABASE IF EXISTS ${db_name};"
rm -rf "${install_dir}/web/sites/default/civicrm.settings.php" "${install_dir}/web/sites/default/settings.php" "${install_dir}/web/sites/default/files/"
print-finish

print-header "Add Civi vhost..."
# Routing
if ! grep -qs "${routing}" /etc/hosts; then
    echo "${routing}" | sudo tee -a /etc/hosts >/dev/null
fi
# Document root
mkdir -p "${doc_root}"
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

print-header "Add Civi DB..."
mysql -u"${db_user_name}" -p"${db_user_pass}" --silent -e "CREATE DATABASE IF NOT EXISTS ${db_name} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
print-finish

print-header "Composer install..."
composer install --working-dir="${install_dir}"
print-finish

print-header "Install Drupal..."
"${install_dir}/vendor/bin/drush" site:install \
    minimal \
    --db-url="mysql://${db_user_name}:${db_user_pass}@localhost:3306/${db_name}" \
    --account-pass="${civi_pass}" \
    --site-name="${civi_site}" \
    --yes
sudo chown -R "${USER}:www-data" "${install_dir}"
sudo chmod -R u+w,g+r "${install_dir}"
print-finish

print-header "Enable Drupal modules..."
"${install_dir}/vendor/bin/drush" pm:enable --yes "${drupal_modules}"
print-finish

print-header "Enable Drupal theme..."
"${install_dir}/vendor/bin/drush" theme:enable --yes "${drupal_theme}"
print-finish

print-finish "Drupal installed!"

print-header "Install CiviCRM..."
cv core:install \
    --no-interaction \
    --cwd="${install_dir}" \
    --lang=en_GB \
    --cms-base-url="http://${civi_domain}" \
    --model paths.cms.root.path="${doc_root}"
sudo chown -R "${USER}:www-data" "${install_dir}"
sudo chmod -R u+w,g+r "${install_dir}"
print-finish

print-header "Update civicrm.settings.php..."
mkdir -p "${install_dir}/web/extensions"
sudo chgrp www-data "${install_dir}/web/extensions"
sed -i \
    -e "/\$civicrm_setting\['domain'\]\['extensionsDir'\]/ c \$civicrm_setting['domain']['extensionsDir'] = '[cms.root]/extensions';" \
    -e "/\$civicrm_setting\['domain'\]\['extensionsURL'\]/ c \$civicrm_setting['domain']['extensionsURL'] = '[cms.root]/extensions';" \
    -e "s@\['cms'\]\['root'\]@\['cms.root'\]@" \
    "${install_dir}/web/sites/default/civicrm.settings.php"
print-finish

print-header "Clear cache..."
sudo -u www-data "${install_dir}/vendor/bin/drush" cache:rebuild
sudo -u www-data cv flush --cwd="${install_dir}"
print-finish

print-header "Set permissions..."
sudo chmod g+w "${install_dir}/web/extensions"
sudo chmod -R g+w "${install_dir}/web/sites/default/files"
print-finish

print-finish "CiviCRM installed!"

exit 0
