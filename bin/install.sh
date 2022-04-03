#!/usr/bin/env bash
#####################
## civi-zero       ##
##                 ##
## Install CiviCRM ##
#####################

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

exit 0
