# shellcheck shell=bash
######################
## civi-zero        ##
##                  ##
## Function library ##
######################

##################
## FORMAT CODES ##
##################

TXT_NORM="\e[0m"
TXT_BOLD="\e[1m"
TXT_RED="\e[31m"
TXT_YELLOW="\e[33m"
TXT_GREEN="\e[32m"
TXT_BLUE="\e[34m"

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
    echo -e "${TXT_BLUE}${TXT_BOLD}${msg}${TXT_NORM}"
    for ((i = 0 ; i < ${#msg} ; i++)); do
        echo -ne "${TXT_BLUE}${TXT_BOLD}=${TXT_NORM}"
    done
    echo
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
