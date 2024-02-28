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
    local header="${*}"
    echo
    # shellcheck disable=SC2086
    echo -e ${BACK_BLUE}${header}${TXT_NORM}
    echo -ne "${BACK_BLUE}"
    for ((i = 0 ; i < ${#header} ; i++)); do
        echo -n "~"
    done
    echo -e "${TXT_NORM}"
}

## Print header
##
## @param    $*  Message
########################
print-header() {
    # shellcheck disable=SC2086
    echo -e ${TXT_YELLOW}${*}${TXT_NORM}
}

## Print status message
##
## @param    $*  Message
########################
print-status() {
    # shellcheck disable=SC2086
    echo -ne ${TXT_YELLOW}${*}${TXT_NORM}
}

## Print OK message
##
## @param    $*  Message
## @default      Done
########################
# shellcheck disable=SC2120
print-finish() {
    # shellcheck disable=SC2086
    echo -e ${TXT_GREEN}${TXT_BOLD}${*:-Done.}${TXT_NORM}
}

## Print error message
##
## @param    $*  Message
########################
print-error() {
    # shellcheck disable=SC2086
    echo -e ${TXT_RED}${TXT_BOLD}${*}${TXT_NORM} >&2
}

## Join arguments by char
##
## @param    $1  Joining character
## @param    $*  Items to join
##################################
implode() {
    local IFS="${1:?"Field separator missing"}"
    shift
    echo ${*}
}
