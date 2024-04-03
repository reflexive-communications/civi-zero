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
[[ -r "${base_dir}/cfg/install.local" ]] && . "${base_dir}/cfg/install.local"

print-header Install Apache...
sudo apt-get --quiet install --yes --no-install-recommends --no-upgrade apache2
sudo a2enmod "${apache_modules[@]}"
sudo systemctl enable apache2.service
sudo systemctl restart apache2.service
print-finish

print-header Install MariaDB...
curl -LsS -O https://r.mariadb.com/downloads/mariadb_repo_setup
echo "${mariadb_repo_setup_checksum}  mariadb_repo_setup" | sha256sum --check --strict -
sudo bash mariadb_repo_setup --mariadb-server-version="${mariadb_version}"
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
sudo apt-get --quiet install --yes --no-install-recommends --no-upgrade "${php_extensions[@]}"
sudo update-alternatives --set php "/usr/bin/php${php_version}"
print-finish

print-status Config PHP...
sudo cp "${base_dir}/cfg/civi.php.ini" "/etc/php/${php_version}/mods-available/"
[[ -e "/etc/php/${php_version}/fpm/conf.d/99-civi.ini" ]] || sudo ln -s "/etc/php/${php_version}/mods-available/civi.php.ini" "/etc/php/${php_version}/fpm/conf.d/99-civi.ini"
[[ -e "/etc/php/${php_version}/cli/conf.d/99-civi.ini" ]] || sudo ln -s "/etc/php/${php_version}/mods-available/civi.php.ini" "/etc/php/${php_version}/cli/conf.d/99-civi.ini"
sudo sed -i \
    -e "s@{{ xdebug.mode }}@${php_xdebug_mode}@g" \
    "/etc/php/${php_version}/mods-available/civi.php.ini"
print-finish

print-status Install PHP tools...
sudo curl -LsS -o "${local_bin}/composer" "${url_composer}"
sudo curl -LsS -o "${local_bin}/cv" "${url_cv}"
sudo chmod +x "${local_bin}/composer"
sudo chmod +x "${local_bin}/cv"
print-finish

exit 0
