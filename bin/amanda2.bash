#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/utils

MAX_SUN_ALT=-10
function sunIsNotUp {
  local SUN_ALT=`sun | grep -o 'alt=[0-9\.\-]\+' | cut -c5-`
  if [ ${SUN_ALT%.*} -gt ${MAX_SUN_ALT%.*} ]
  then
    #debug "Sun is UP. Altitude is $SUN_ALT deg."
    return 1
  else
    #debug "Sun altitude is $SUN_ALT deg."
    return 0
  fi
}

RA1=14:46:59.96
DEC1=02:53:30.4
NUM1=1
EXP1=300
BIN1=2
FILTERS1=g-band
MIN_ALT1=30
NAME1=2XMM_J144659.9_025330
WAIT4TIME=05:00
DELAY_S=0

sunset $MAX_SUN_ALT

#wait for certain time
#wait4time $WAIT4TIME
wait4target $RA1 $DEC1 $MIN_ALT1

#open observatory
if [ $? -eq 0 ]; then
    crackit
else
    alert "Error. wait4time script failed."
fi

while sunIsNotUp
do
    #take images
    iloop $NUM1 $EXP1 $BIN1 $FILTERS1 $RA1 $DEC1 $NAME1
    #if there is a fatal error, shut this guy down
    RESULT=$?
    if [ $RESULT -eq 1 ]; then
        squeezeit
        exit 1
    fi
    if [ $RESULT -eq 2 ]; then
        squeezeit
        exit 1
    fi
    if [ $RESULT -eq 0 ]; then
        debug "Pausing between observations for $DELAY_S seconds..."
        sleep $DELAY_S
    else
        sleep 60
    fi
done

squeezeit