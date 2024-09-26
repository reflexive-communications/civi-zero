# shellcheck shell=bash
######################
## civi-zero        ##
##                  ##
## Function library ##
######################

##################
## FORMAT CODES ##
##################

TXT_NORM=$(tput sgr0 2>/dev/null || printf '')
TXT_BOLD=$(tput bold 2>/dev/null || printf '')
TXT_RED=$(tput setaf 1 2>/dev/null || printf '')
TXT_GREEN=$(tput setaf 2 2>/dev/null || printf '')
TXT_YELLOW=$(tput setaf 3 2>/dev/null || printf '')
BACK_BLUE=$(tput setab 4 2>/dev/null || printf '')

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
    local IFS="${1:?Field separator missing}"
    shift
    echo "${*}"
}
