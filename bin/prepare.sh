#!/usr/bin/env bash
#######################
## civi-zero         ##
##                   ##
## Setup environment ##
## Apache, MariaDB   ##
## PHP & tools       ##
#######################

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

print-header Install Apache...
sudo apt-get --quiet install --yes --no-install-recommends --no-upgrade apache2
sudo a2enmod "${apache_modules[@]}"
sudo systemctl enable apache2.service
sudo systemctl restart apache2.service
print-finish

print-header Verify Apache version...
apachectl -V
print-finish

print-header Install MariaDB...
curl -LsS -O https://r.mariadb.com/downloads/mariadb_repo_setup
sudo bash mariadb_repo_setup --mariadb-server-version="${mariadb_version}" --skip-maxscale
sudo apt-get --quiet install --yes --no-install-recommends --no-upgrade mariadb-server mariadb-client
sudo mysql_install_db --user=mysql
sudo systemctl enable mariadb.service
sudo systemctl restart mariadb.service
print-finish

print-header Verify MySQL version...
mysql --version
sudo mysql -e "SELECT VERSION()"
print-finish

print-header Install PHP...
sudo add-apt-repository ppa:ondrej/php
sudo apt-get --quiet install --yes --no-install-recommends --no-upgrade "${php_extensions[@]}"
sudo update-alternatives --set php "/usr/bin/php${php_version}"
print-finish

print-status Config PHP...
sudo install --mode=0644 "${base_dir}/cfg/civi.php.ini" "/etc/php/${php_version}/mods-available/"
[[ -e "/etc/php/${php_version}/fpm/conf.d/99-civi.ini" ]] || sudo ln -s "/etc/php/${php_version}/mods-available/civi.php.ini" "/etc/php/${php_version}/fpm/conf.d/99-civi.ini"
[[ -e "/etc/php/${php_version}/cli/conf.d/99-civi.ini" ]] || sudo ln -s "/etc/php/${php_version}/mods-available/civi.php.ini" "/etc/php/${php_version}/cli/conf.d/99-civi.ini"
sudo sed -i \
    -e "s@{{ xdebug.mode }}@${php_xdebug_mode}@g" \
    "/etc/php/${php_version}/mods-available/civi.php.ini"
print-finish

print-header Verify PHP version...
php --version
print-finish

print-status Install PHP tools...
tmp_file=$(mktemp)
curl -LsS -o "${tmp_file}" "${url_composer}"
echo "${sha_composer}  ${tmp_file}" | sha256sum --check --strict --status -
sudo install --mode=0755 --no-target-directory "${tmp_file}" "${local_bin}/composer"
sudo curl -LsS -o "${local_bin}/cv" "${url_cv}"
sudo chmod +x "${local_bin}/cv"
print-finish

print-header Verify PHP tools version...
composer --version
cv --version
print-finish

exit 0
