#!/usr/bin/env bash
##########################
## civi-zero            ##
##                      ##
## Setup CI environment ##
##########################

#################
## SCRIPT START #
#################

# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Include library
base_dir="$(builtin cd "$(dirname "${0}")" >/dev/null 2>&1 && pwd)"
source "${base_dir}/library.sh"

print-header "Install Apache..."
sudo add-apt-repository --yes ppa:ondrej/apache2
sudo apt-get install --yes --no-install-recommends apache2 libapache2-mod-fcgid libapache2-mod-security2
sudo a2enmod actions expires headers rewrite
print-finish
