#!/bin/bash
# ------------------------------------------------------------------
# [Author] Title
#          Description
# ------------------------------------------------------------------

NAME=$(basename "$0")
AUTHOR="Rickard Hillebrink"
VERSION=1.0.0
TEMPLATE_VERSION=1.0.2
DESCRIPTION="Description of what this script will do"
USAGE="Usage: $NAME -h args"
DAY=`date +%A`
MONTH=`date +%B`
YEAR=`date +%Y`
LOG=~/logs


usage() {
  printf "\nNAME\n\t$NAME\nVERSION\n\t$VERSION\n\nAuthor\n\t$AUTHOR\n
DESCRIPTION\n
\t$DESCRIPTION\n
OPTIONS
\n\t-h or --help\n\t\tprint this message
"
}

writeToLog() {
  printf "
***************************
  `date` -> $1
***************************
" >> $LOG/$NAME.log
}

# --- Options processing -------------------------------------------
flags()
{
    while test $# -gt 0
    do
        case "$1" in
        -v|--verbose)
            export VERBOSE="1"
            ;;
        -h|--help)
            usage;;
        *) usage;;
        esac

        # and here we shift to the next argument 
        shift
    done
}
flags "$@"

# --- Body --------------------------------------------------------
#  SCRIPT LOGIC GOES HERE
echo $param1
echo $param2
# ---------------------------------------------------------