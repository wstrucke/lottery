#!/bin/bash

function check_win {
  if [[ $PB -eq 1 ]]; then
    check_win_pb $1 $2
  else
    check_win_mm $1 $2
  fi
}

function check_win_mm {
# $1 numbers matched
# $2 bonus matched (0|1)
case "$1+$2" in
  "5+1") echo -n "JACKPOT:  "; W=$(($W+636000000));;
  "5+0") echo -n "\$1,000,000: "; W=$(($W+1000000));;
  "4+1") echo -n "\$5,000:  "; W=$(($W+5000));;
  "4+0") echo -n "\$500:     "; W=$(($W+500));;
  "3+1") echo -n "\$50:     "; W=$(($W+50));;
  "3+0") echo -n "\$5:       "; W=$(($W+5));;
  "2+1") echo -n "\$5:      "; W=$(($W+5));;
  "1+1") echo -n "\$2:       "; W=$(($W+2));;
  "0+1") echo -n "\$1:       "; W=$(($W+1));;
  "1+0") test $DEBUG -eq 1 && echo -n "\$0:       " || return 1;;
  *) return 1;;
esac
return 0
}

function check_win_pb {
# $1 numbers matched
# $2 bonus matched (0|1)
case "$1+$2" in
  "5+1") echo -n "JACKPOT:  "; W=$(($W+800000000));;
  "5+0") echo -n "\$1,000,000: "; W=$(($W+1000000));;
  "4+1") echo -n "\$10,000: "; W=$(($W+10000));;
  "4+0") echo -n "\$100:     "; W=$(($W+100));;
  "3+1") echo -n "\$100:     "; W=$(($W+100));;
  "3+0") echo -n "\$7:       "; W=$(($W+7));;
  "2+1") echo -n "\$7:      "; W=$(($W+7));;
  "1+1") echo -n "\$4:       "; W=$(($W+4));;
  "0+1") echo -n "\$4:       "; W=$(($W+4));;
  "1+0") test $DEBUG -eq 1 && echo -n "\$0:       " || return 1;;
  *) return 1;;
esac
return 0
}

function colorize_output {
  local string="$1"; shift
  local c=0
  echo "$string" |grep -qE '(^| )('$1'|'$2'|'$3'|'$4'|'$5')( |$)'
  while [ $? -eq 0 ]; do
    string=$( echo -e "$( echo $string |sed -E 's/(^| )('$1'|'$2'|'$3'|'$4'|'$5')( |$)/\1'$G'\2'$STOP'\3/' )" )
    c=$((c+1))
    if [[ $c -gt 10 ]]; then echo "error"; exit 1; fi
    echo "$string" |grep -qE '(^| )('$1'|'$2'|'$3'|'$4'|'$5')( |$)'
  done
  echo -e "$( echo $string |sed -E 's/ ([0-9]{5})/ '$B'[\1]'$STOP'/; s/\+'$6' /\+'${G}${6}${STOP}' /' )"
  return 0
}

function usage {
  cat <<_EOF >&2
Usage: $0 [--poweball|--mega] # # # # # #

numbers.txt must exist with your picks, in the format:
1 2 3 4 5 +6 ticket_id\n

Valid numbers for Powerball are 1-69 +1-26
_EOF
  exit 1
}

# Defaults
MM=1
PB=0

# Color
B="\\\033[38;5;32m"
G="\\\033[38;5;34m"
STOP="\\\033[39m"

if [[ "${1:0:1}" == "-" ]]; then case $1 in
  --powerball) PB=1; MM=0;;
  --mega) PB=0; MM=1;;
  *) usage;;
esac; shift; fi

if [ $# -ne 6 ]; then usage; fi
if [ ! -f numbers.txt ]; then usage; fi

DEBUG=0
W=0
N1="$1"
N2="$2"
N3="$3"
N4="$4"
N5="$5"
N6="$6"

while read line; do
  BONUS=0
  MATCH=0
  echo $line |grep -qE '^'$N1' ' && MATCH=$(($MATCH+1))
  echo $line |grep -qE " $N2 " && MATCH=$(($MATCH+1))
  echo $line |grep -qE " $N3 " && MATCH=$(($MATCH+1))
  echo $line |grep -qE " $N4 " && MATCH=$(($MATCH+1))
  echo $line |grep -qE " $N5 " && MATCH=$(($MATCH+1))
  echo $line |grep -qE '\+'$N6'' && BONUS=1
  check_win $MATCH $BONUS
  test $? -eq 0 && colorize_output "$line" $N1 $N2 $N3 $N4 $N5 $N6
done <numbers.txt

if [[ "$W" -eq 0 ]]; then
  printf "\nSorry, no winnings today.\n\n"
else
  printf "\nYou won $%'d.00!\n\n" $W
fi

exit 0
