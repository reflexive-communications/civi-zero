#!/usr/bin/env bash
#################################################
## civi-zero                                   ##
##                                             ##
## Install CiviCRM                             ##
##                                             ##
## Required options:                           ##
##   $1   Install dir                          ##
##                                             ##
## After required options, you can give flags: ##
##   --sample: load sample data to CiviCRM     ##
#################################################

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
install_dir="${1?:"Install dir missing"}"
install_dir=$(realpath "${install_dir}")
shift
routing="127.0.0.1 ${civi_domain}"
doc_root="${install_dir}/web"
config_template="${install_dir}/web/modules/contrib/civicrm/civicrm.config.php.drupal"

# Parse flags
load_sample=
for flag in "${@}"; do
    case "${flag}" in
        --sample) load_sample=1 ;;
        *) ;;
    esac
done

print-header "Purge instance..."
sudo mysql -e "DROP DATABASE IF EXISTS ${civi_db_name}"
sudo rm -rf "${install_dir}/web/sites/default/civicrm.settings.php" "${install_dir}/web/sites/default/settings.php" "${install_dir}/web/sites/default/files/"
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
sudo cp "${install_dir}/cfg/vhost.conf" "/etc/apache2/sites-available/${civi_domain}.conf"
sudo sed -i \
    -e "s@{{ site }}@${civi_domain}@g" \
    -e "s@{{ doc_root }}@${doc_root}@g" \
    "/etc/apache2/sites-available/${civi_domain}.conf"
sudo a2ensite "${civi_domain}.conf"
sudo systemctl reload apache2.service
print-finish

print-header "Add Civi DB..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS ${civi_db_name} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"
print-finish

print-header "Add Civi DB user..."
sudo mysql -e "CREATE USER IF NOT EXISTS ${civi_db_user_name}@localhost IDENTIFIED BY '${civi_db_user_pass}'"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${civi_db_name}.* TO '${civi_db_user_name}'@'localhost'"
sudo mysql -e "GRANT SUPER ON *.* TO '${civi_db_user_name}'@'localhost'"
sudo mysql -e "FLUSH PRIVILEGES"
print-finish

print-header "Composer install..."
composer install --working-dir="${install_dir}"
print-finish

print-header "Install Drupal..."
"${install_dir}/vendor/bin/drush" site:install \
    minimal \
    --db-url="mysql://${civi_db_user_name}:${civi_db_user_pass}@localhost:3306/${civi_db_name}" \
    --account-name="${civi_user}" \
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
mkdir -p "${install_dir}/web/extensions"
print-finish

print-header "Config CiviCRM bin/setup.sh..."
cp "${install_dir}/vendor/civicrm/civicrm-core/bin/setup.conf.txt" "${install_dir}/vendor/civicrm/civicrm-core/bin/setup.conf"
sed -i \
    -e "/^CIVISOURCEDIR=/ c \CIVISOURCEDIR='${install_dir}'" \
    -e "/^DBNAME=/ c \DBNAME='${civi_db_name}'" \
    -e "/^DBUSER=/ c \DBUSER='${civi_db_user_name}'" \
    -e "/^DBPASS=/ c \DBPASS='${civi_db_user_pass}'" \
    -e "/^GENCODE_CMS=/ c \GENCODE_CMS='drupal8'" \
    "${install_dir}/vendor/civicrm/civicrm-core/bin/setup.conf"
print-finish

print-header "Generate CiviCRM SQL files..."
GENCODE_CONFIG_TEMPLATE="${config_template}" "${install_dir}/vendor/civicrm/civicrm-core/bin/setup.sh" -g
print-finish

if [[ -n "${load_sample}" ]]; then
    print-header "Load sample data..."
    GENCODE_CONFIG_TEMPLATE="${config_template}" "${install_dir}/vendor/civicrm/civicrm-core/bin/setup.sh" -se
    print-finish
fi

print-header "Set permissions..."
# Base
sudo chown -R "${USER}:www-data" "${install_dir}"
sudo chmod -R u+w,g+r "${install_dir}"
# Vendor (enable patching of core files)
sudo chmod -R g+w "${install_dir}/vendor"
# Extensions
sudo chmod -R g+w "${install_dir}/web/extensions"
# Files
sudo chown -R www-data:www-data "${install_dir}/web/sites/default/files"
sudo chmod -R g+w "${install_dir}/web/sites/default/files"
print-finish

print-header "Update civicrm.settings.php..."
sed -i \
    -e "/\$civicrm_setting\['domain'\]\['extensionsDir'\]/ c \$civicrm_setting['domain']['extensionsDir'] = '[cms.root]/extensions';" \
    -e "/\$civicrm_setting\['domain'\]\['extensionsURL'\]/ c \$civicrm_setting['domain']['extensionsURL'] = '[cms.root]/extensions';" \
    -e "s@\['cms'\]\['root'\]@\['cms.root'\]@" \
    -e "/(\!defined('CIVICRM_TEMPLATE_COMPILE_CHECK'))/,+2 s@^//@@" \
    -e "/CIVICRM_TEMPLATE_COMPILE_CHECK/ s/FALSE/TRUE/" \
    "${install_dir}/web/sites/default/civicrm.settings.php"
print-finish

print-header "Redirect mail to database..."
sudo -u www-data cv api4 \
    --no-interaction \
    --cwd="${install_dir}" \
    Setting.set \
    '{"values":{"mailing_backend":{"outBound_option":5}}}'
print-finish

print-header "Clear cache..."
sudo -u www-data "${install_dir}/vendor/bin/drush" cache:rebuild
sudo -u www-data cv flush --cwd="${install_dir}"
print-finish

print-header "Login to site..."
cookies=$(mktemp)
OTP=$("${install_dir}/vendor/bin/drush" uli --no-browser --uri="${civi_domain}")
return_code=$(curl -LsS -o /dev/null -w"%{http_code}" --cookie-jar "${cookies}" "${OTP}")
if [[ "${return_code}" != "200" ]]; then
    print-error "Failed to login to site"
    exit 1
fi
print-finish

print-header "Test Civi: GET /civicrm/contact/search..."
return_code=$(curl -LsS -o /dev/null -w"%{http_code}" --cookie "${cookies}" "${civi_domain}/civicrm/contact/search")
if [[ "${return_code}" != "200" ]]; then
    print-error "Failed to GET /civicrm/contact/search"
    exit 1
fi
print-finish

print-finish "CiviCRM installed!"

exit 0
