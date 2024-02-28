#!/usr/bin/env bash
################################################
## civi-zero                                  ##
##                                            ##
## Config CiviCRM                             ##
##                                            ##
## Options:                                   ##
##   $1 Install dir, where to install CiviCRM ##
################################################

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

# Parse options
install_dir="${1:-${base_dir}}"
install_dir=$(realpath "${install_dir}")
cv_params=(--no-interaction "--cwd=${install_dir}")

print-status Update civicrm.settings.php...
sed -i \
    -e "/(\!defined('CIVICRM_TEMPLATE_COMPILE_CHECK'))/,+2 s@^//@@" \
    -e "/CIVICRM_TEMPLATE_COMPILE_CHECK/ s/FALSE/TRUE/" \
    -e "/(\!defined('CIVICRM_LOG_HASH'))/,+2 s@^//@@" \
    -e "/CIVICRM_LOG_HASH/ s/TRUE/FALSE/" \
    -e "/define( 'CIVICRM_SITE_KEY'/ c define( 'CIVICRM_SITE_KEY', '${civi_sitekey}');" \
    "${install_dir}/web/sites/default/civicrm.settings.php"
print-finish

print-header Set API key for system user...
contact_id=$(sudo -u www-data cv api4 "${cv_params[@]}" --out=list UFMatch.get +s contact_id +w uf_id=1)
sudo -u www-data cv api4 "${cv_params[@]}" Contact.update +v "api_key=${civi_apikey}" +w "id=${contact_id}"
print-finish

print-header Set default from address...
record=$(cat <<EOF
{
    "values": {
        "label": "\"${civi_user}\" <${civi_mail}>",
        "name": "\"${civi_user}\" <${civi_mail}>"
    },
    "where":[["option_group_id:name","=","from_email_address"]]
}
EOF
)
echo "${record}" | sudo -u www-data cv api4 "${cv_params[@]}" OptionValue.update --in=json
print-finish

print-header Apply settings...
json=$(implode , "${civi_configs[@]}")
json=$(printf '{"values":{%s}}' "${json}")
sudo -u www-data cv api4 "${cv_params[@]}" Setting.Set "${json}"
print-finish

print-header Setup default mailbox...
localpart=$(cut -d@ -f1 <<<"${civi_mail}")
domain=$(cut -d@ -f2 <<<"${civi_mail}")
# Compose JSON record
record=$(cat <<EOF
[{
  "id": 1,
  "domain_id": 1,
  "name": "bounce",
  "is_default": true,
  "domain": "${domain}",
  "localpart": "${localpart}",
  "return_path": null,
  "protocol": "3",
  "server": "localhost",
  "port": null,
  "username": "user",
  "password": "pass",
  "is_ssl": false,
  "source": null,
  "activity_status": null,
  "is_non_case_email_skipped": false,
  "is_contact_creation_disabled_if_no_match": false
}]
EOF
)
record=$(tr -d '[:space:]' <<<"${record}")
sudo -u www-data cv api4 "${cv_params[@]}" MailSettings.Save records="${record}" '{"reload":true}'
print-finish

print-finish CiviCRM configured!

exit 0
