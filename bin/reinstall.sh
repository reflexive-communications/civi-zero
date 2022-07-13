#!/usr/bin/env bash
#################################################
## civi-zero                                   ##
##                                             ##
## Reinstall CiviCRM                           ##
## Quickly reinitialize Civi DB, keep files    ##
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
base_dir="$(builtin cd "$(dirname "${0}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=bin/library.sh
. "${base_dir}/library.sh"

# Include configs
# shellcheck source=cfg/install.cfg
. "${base_dir}/../cfg/install.cfg"
# shellcheck disable=SC1091
[[ -r "${base_dir}/../cfg/install.local" ]] && . "${base_dir}/../cfg/install.local"

# Parse options
install_dir="${1?:"Install dir missing"}"
shift
config_template="${install_dir}/web/modules/contrib/civicrm/civicrm.config.php.drupal"

# Parse flags
load_sample=
for flag in "${@}"; do
    case "${flag}" in
        --sample) load_sample=1 ;;
        *) ;;
    esac
done

if [[ -n "${load_sample}" ]]; then
    print-header "Init DB & load sample data..."
    GENCODE_CONFIG_TEMPLATE="${config_template}" "${install_dir}/vendor/civicrm/civicrm-core/bin/setup.sh" -se
    print-finish
else
    print-header "Init DB..."
    GENCODE_CONFIG_TEMPLATE="${config_template}" "${install_dir}/vendor/civicrm/civicrm-core/bin/setup.sh" -sd
    print-finish
fi

print-header "Clear cache..."
sudo -u www-data "${install_dir}/vendor/bin/drush" cache:rebuild
sudo -u www-data cv flush --cwd="${install_dir}"
print-finish

print-header "Login to site..."
OTP=$("${install_dir}/vendor/bin/drush" uli --no-browser --uri="${civi_domain}")
curl -LsS -o /dev/null --cookie-jar "$(mktemp)" "${OTP}"
print-finish

print-finish "CiviCRM reinstalled!"

exit 0
