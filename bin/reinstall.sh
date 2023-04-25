#!/usr/bin/env bash
##################################################
## civi-zero                                    ##
##                                              ##
## Reinstall CiviCRM                            ##
## Quickly reinitialize Civi DB, keep files     ##
##                                              ##
## Options:                                     ##
##   $1 Install dir, where to install CiviCRM   ##
##   $* Flags (optional)                        ##
##        --sample: load sample data to CiviCRM ##
##################################################

# Strict mode
set -eufo pipefail
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
[[ "$#" -gt 0 ]] && shift
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

"${base_dir}/bin/clear-cache.sh" "${install_dir}"

print-status "Login to site..."
OTP=$("${install_dir}/vendor/bin/drush" uli --root "${install_dir}" --no-browser --uri="${civi_domain}")
tmp_file=$(mktemp)
curl -LsS -o /dev/null --cookie-jar "${tmp_file}" "${OTP}"
print-finish

print-finish "CiviCRM reinstalled!"

exit 0
