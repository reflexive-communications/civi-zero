#!/usr/bin/env bash
#########################
## civi-zero           ##
##                     ##
## Setup environment   ##
## Apache, PHP & tools ##
#########################

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

print-header "Add apt repository"
sudo add-apt-repository --yes --no-update ppa:ondrej/apache2
sudo add-apt-repository --yes --no-update ppa:ondrej/php
sudo apt-get update
print-finish

print-header "Install Apache..."
sudo apt-get install --yes --no-install-recommends apache2 libapache2-mod-fcgid libapache2-mod-security2
sudo a2enmod actions expires headers rewrite
sudo systemctl enable apache2.service
sudo systemctl restart apache2.service
sudo mkdir -p "${web_root}"
print-finish

print-header "Install PHP..."
sudo apt-get install --yes --no-install-recommends \
    "php${php_version}" \
    "php${php_version}-bcmath" \
    "php${php_version}-bz2" \
    "php${php_version}-cli" \
    "php${php_version}-common" \
    "php${php_version}-curl" \
    "php${php_version}-fpm" \
    "php${php_version}-gd" \
    "php${php_version}-imagick" \
    "php${php_version}-imap" \
    "php${php_version}-intl" \
    "php${php_version}-json" \
    "php${php_version}-ldap" \
    "php${php_version}-mbstring" \
    "php${php_version}-mysql" \
    "php${php_version}-opcache" \
    "php${php_version}-soap" \
    "php${php_version}-zip" \
    "php${php_version}-xdebug" \
    "php${php_version}-xml"
sudo systemctl enable "php${php_version}-fpm.service"
sudo systemctl restart "php${php_version}-fpm.service"
sudo a2enconf "php${php_version}-fpm"
sudo systemctl reload apache2.service
print-finish

print-header "Install PHP tools..."
sudo curl -LsS -o "${local_bin}/composer2" "${url_composer2}"
sudo curl -LsS -o "${local_bin}/phpunit8" "${url_phpunit8}"
sudo curl -LsS -o "${local_bin}/cv" "${url_cv}"
sudo chmod +x "${local_bin}/composer2"
sudo chmod +x "${local_bin}/phpunit8"
sudo chmod +x "${local_bin}/cv"
print-finish

exit 0
