# shellcheck shell=bash
######################
## civi-zero        ##
##                  ##
## Function library ##
#######################

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

## Print header
##
## @param    $*  Message
########################
print-header(){
    echo
    echo -e "${TXT_YELLOW}${*}${TXT_NORM}"
}

## Print OK message
##
## @param    $*  Message
## @default      Done
########################
print-finish(){
    echo -e "${TXT_GREEN}${TXT_BOLD}${*:-"Done."}${TXT_NORM}"
}

## Print error message
##
## @param    $*  Message
########################
print-error(){
    echo -e "${TXT_RED}${TXT_BOLD}${*}${TXT_NORM}" >&2
}
