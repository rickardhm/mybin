#!/bin/bash
# ------------------------------------------------------------------
# [Author] Title
#          Description
# ------------------------------------------------------------------
export BLACK='\033[0;30m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export BROWN='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT_GREY='\033[0;37m'
export DARK_GREY='\033[1;30m'
export LIGHT_RED='\033[1;31m'
export LIGHT_GREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export LIGHT_BLUE='\033[1;34m'
export LIGHT_PURPLE='\033[1;35m'
export LIGHT_CYAN='\033[1;36m'
export WHITE='\033[1;37m'
export DEFAULT='\033[0m'

NAME=$(basename "$0")
AUTHOR="Rickard Hillebrink"
VERSION=1.0.2
DESCRIPTION="A simple diary to take notes of daily event. Each days comes in the form; what have I done yesterday and what will I do tomorrow"
USAGE="Usage: $NAME -ivhdbanpw args"
DAY=`date +%A`
MONTH=`date +%B`
YEAR=`date +%Y`
DIARY_DATE=`date +%Y-%m-%d:%A_vecka_%V`
DIARY_HOME=/d/home/nextcloud/.diary
DIARY_FILE="$DIARY_HOME/$NAME.txt"
LOG=/d/home/logs
TMP_DIARY_FILE="$DIARY_HOME/tmp_$NAME.txt"
DIARY_HISTORY_DIR=$DIARY_HOME
REMOTE_BACKUP_DIR=~/tmp

usage() {
  printf "\nNAME\n\t$NAME\n\n$USAGE\n
$DESCRIPTION\n
OPTIONS\n
\t-v or --version\n\t\t gives informations about the current version of the script and the templat that was used to create this script\n
\t-h or --help\n\t\tprint this message\n
\t-i or --init\n\t\tinitiate a new diary\n
\t-b or --backup\n\t\tmakes backup of the diary\n
\t-a or --add\n\t\tadd notes to diary\n
\t-e or --edit\n\t\tedit the diary\n
\t-r or --read\n\t\treads diary data from a specic month.\n
\t-s or --search\n\t\tsearch diary entries\n
\nAuthor
\t$AUTHOR"
}

init_diary() {
  printf "
**************************
  Dagbok för $AUTHOR
***************************\n
$DIARY_DATE
Har gjort:
" >> $DIARY_FILE

cat > $TMP_DIARY_FILE >> $DIARY_FILE

printf "Skall göra:
" >> $DIARY_FILE

rm $TMP_DIARY_FILE
}
search_diary() {
  grep --color -i $OPTARG $DIARY_HOME/*.bak $OPTARG $DIARY_HOME/dagbok.txt
}
readFromFile() {
  case $OPTARG in

    "1" | "jan" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_januari.bak"
    ;;
    "2" | "feb" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_februari.bak"
    ;;
    "3" | "mar" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_mars.bak"
    ;;
    "4" | "apr" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_april.bak"
    ;;
    "5" | "maj" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_maj.bak"
    ;;
    "6" | "jun" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_juni.bak"
    ;;
    "7" | "jul" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_juli.bak"
    ;;
    "8" | "aug" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_augusti.bak"
    ;;
    "9" | "sep" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_september.bak"
    ;;
    "10" | "okt" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_oktober.bak"
    ;;
    "11" | "nov" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_november.bak"
    ;;
    "12" | "dec" )
      input=$DIARY_HISTORY_DIR"/$NAME_"$YEAR"_december.bak"
    ;;
    *)
      input="$DIARY_FILE"
    ;;
  esac
  while IFS= read -r line
  do
    if [[ $line =~ ^'  ' ]]
    then
      printf "$GREEN$line$DEFAULT"
    else
      printf "$PURPLE$line$DEFAULT"
    fi
  echo
  done < "$input"
}

writeToLog() {
  printf "
***************************
  `date` -> $1
***************************
" >> $LOG/$NAME.log
}

startLog() {
  printf "
***************************
 `date +"%A %Y-%m-%d"`
 `date +"%T"` $1
" >> $LOG/$NAME.log
}
appendLog() {
  printf " `date +"%T"` $1
" >> $LOG/$NAME.log
}
endLog() {
  printf " `date +"%T"` $1
***************************
" >> $LOG/$NAME.log
}

collect_will_do() {
  echo "writes comment from 'Skall göra' for the previous day to $TMP_DIARY_FILE"
  awk -v RS='(^|\n)Skall göra:\n' 'END{printf "%s", $0}' < $DIARY_FILE  >> $TMP_DIARY_FILE
    if grep -q 'Har gjort:' $TMP_DIARY_FILE; then
    true > $TMP_DIARY_FILE
  fi
cat < $TMP_DIARY_FILE
}

writeDate() {
  collect_will_do

  printf "
$DIARY_DATE
Har gjort:
" >> $DIARY_FILE

cat < $TMP_DIARY_FILE >> $DIARY_FILE

printf "Skall göra
" >>$DIARY_FILE

rm $TMP_DIARY_FILE
}

read_last_entry() {
  writeToLog "read_last_entry"
  awk -v RS='(^|\n)Skall göra:\n' 'END{printf "%s", $0}' <$DIARY_FILE
}

makeBackup() {
  #if bak file does not exist, move DIARY to new bak-file and create new empty DIARY
  # creates a zipped backup. the backup will be overwritten after seven days
  writeDate
  startLog "Backup to $TMPDIR"
  TMPDIR=$REMOTE_BACKUP_DIR
  if [ ! -d $REMOTE_BACKUP_DIR ]; then
    TMPDIR=~
  fi
  if [ -f $DIARY_HISTORY_DIR/$NAME_$YEAR\_$MONTH.bak ]; then
    appendLog "backup the $DIARY_FILE file to $DIARY_HISTORY_DIR"
    cp $DIARY_FILE $DIARY_HISTORY_DIR/$NAME_$YEAR\_$MONTH.bak
  else
    appendLog "create new $DIARY_FILE file at $DIARY_HISTORY_DIR"
    mv $DIARY_FILE $DIARY_HISTORY_DIR/$NAME_$YEAR\_$MONTH.bak
    init_diary
  fi
  DIR=$PWD
  cd $DIARY_HOME
  tar cvzf $TMPDIR/$NAME_$DAY.tar.tz *
  appendLog "making backup file: $TMPDIR/$NAME_$DAY.tar.tz"
  cd $DIR
  endLog "my work here is done"
}

# --- Options processing -------------------------------------------
if [ $# == 0 ] ; then
  readFromFile
fi

flags()
{
    while test $# -gt 0
    do
        case "$1" in
        -v|--verbose)
          export VERBOSE="1"
          ;;
        -h|--help)
          usage
          ;;
        -i|--init)
          init_diary
          ;;
        -b|--backup)
          makeBackup
          ;;
        -a|--add)
          echo "add to $DIARY_FILE "$OPTARG
          echo "  "$OPTARG >> $DIARY_FILE
          ;;
        -r|--read)
          readFromFile $OPTARG
          ;;
        -e|--edit)
          nano $DIARY_FILE
          ;;
        -s|--search)
          search_diary
          ;;
        *) usage;;
        esac

        # and here we shift to the next argument 
        shift
    done
}
flags "$@"

#shift $(($OPTIND - 1))
param1=$1
param2=$2

# --- Locks -------------------------------------------------------
LOCK_FILE=/tmp/$SUBJECT.lock
if [ -f "$LOCK_FILE" ]; then
   echo "Script is already running"
   exit
fi

trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE

# --- Body --------------------------------------------------------
#  SCRIPT LOGIC GOES HERE
echo $param1
echo $param2
# ---------------------------------------------------------