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
  "5+1") echo -n "JACKPOT:  "; W=$(($W+500000000));;
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

function usage {
  echo "Usage: $0 [--poweball|--mega] # # # # # #" >&2
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

while read line; do
  BONUS=0
  MATCH=0
  echo $line |grep -qE '^'$1' ' && MATCH=$(($MATCH+1))
  echo $line |grep -qE " $2 " && MATCH=$(($MATCH+1))
  echo $line |grep -qE " $3 " && MATCH=$(($MATCH+1))
  echo $line |grep -qE " $4 " && MATCH=$(($MATCH+1))
  echo $line |grep -qE " $5 " && MATCH=$(($MATCH+1))
  echo $line |grep -qE '\+'$6'' && BONUS=1
  check_win $MATCH $BONUS
  test $? -eq 0 && echo -e "$( echo $line |sed -E 's/([0-9]{5})/'$B'[\1]'$STOP'/; s/(^|[ +])('$1'|'$2'|'$3'|'$4'|'$5'|'$6')([ +]|$)/\1'$G'\2\3'$STOP'/g' )"
done <numbers.txt

if [[ "$W" -eq 0 ]]; then
  printf "\nSorry, no winnings today.\n\n"
else
  printf "\nYou won $%'d.00!\n\n" $W
fi

exit 0
