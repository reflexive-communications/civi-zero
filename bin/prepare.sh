#!/usr/bin/env bash
#########################
## civi-zero           ##
##                     ##
## Setup environment   ##
## Apache, PHP & tools ##
#########################

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Include library
base_dir="$(builtin cd "$(dirname "${0}")" >/dev/null 2>&1 && pwd)"
. "${base_dir}/library.sh"

# Include configs
. "${base_dir}/../install.conf"
[[ -r "${base_dir}/../install.local" ]] && . "${base_dir}/../install.local"

print-header "Install Apache..."
sudo apt-get install --yes --no-install-recommends --no-upgrade apache2 libapache2-mod-fcgid libapache2-mod-security2
sudo a2enmod "${apache_modules[@]}"
sudo systemctl enable apache2.service
sudo systemctl restart apache2.service
print-finish

print-header "Install MariaDB..."
curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo bash mariadb_repo_setup --mariadb-server-version="${mariadb_version}"
sudo apt-get install --yes --no-install-recommends --no-upgrade mariadb-server mariadb-client
sudo mysql_install_db --user=mysql
sudo systemctl enable mariadb.service
sudo systemctl restart mariadb.service
print-finish

print-header "Install PHP..."
sudo apt-get install --yes --no-install-recommends --no-upgrade "${php_extensions[@]}"
sudo systemctl enable "php${php_version}-fpm.service"
sudo systemctl restart "php${php_version}-fpm.service"
sudo a2enconf "php${php_version}-fpm"
sudo systemctl reload apache2.service
sudo update-alternatives --set php "/usr/bin/php${php_version}"
print-finish

print-header "Install PHP tools..."
sudo curl -LsS -o "${local_bin}/composer" "${url_composer}"
sudo curl -LsS -o "${local_bin}/cv" "${url_cv}"
sudo chmod +x "${local_bin}/composer"
sudo chmod +x "${local_bin}/cv"
print-finish

exit 0
