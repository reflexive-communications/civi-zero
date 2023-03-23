# shellcheck shell=bash
######################
## civi-zero        ##
##                  ##
## Function library ##
######################

##################
## FORMAT CODES ##
##################

export TXT_NORM="\e[0m"
export TXT_BOLD="\e[1m"
export TXT_RED="\e[31m"
export TXT_GREEN="\e[32m"
export TXT_YELLOW="\e[33m"
export TXT_BLUE="\e[34m"
export TXT_PURPLE="\e[35m"
export BACK_BLUE="\e[44m"

###############
## FUNCTIONS ##
###############

## Print section header
##
## @param    $*  Message
########################
print-section() {
    local msg="${*}"
    echo
    echo -e "${BACK_BLUE}${msg}"
    for ((i = 0 ; i < ${#msg} ; i++)); do
        echo -n =
    done
    echo -e "${TXT_NORM}"
}

## Print header
##
## @param    $*  Message
########################
print-header() {
    echo
    echo -e "${TXT_YELLOW}${*}${TXT_NORM}"
}

## Print OK message
##
## @param    $*  Message
## @default      Done
########################
# shellcheck disable=SC2120
print-finish() {
    echo -e "${TXT_GREEN}${TXT_BOLD}${*:-Done.}${TXT_NORM}"
}

## Print error message
##
## @param    $*  Message
########################
print-error() {
    echo -e "${TXT_RED}${TXT_BOLD}${*}${TXT_NORM}" >&2
}
