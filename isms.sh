#!/bin/bash

# Get the API KEY from your ghasedak.io account
readonly API_KEY=''

function _help_(){
    echo "ERROR ...";
    echo "You should provide three options";
    echo
    echo "command [receiver-phone-number] [sender-line] 'message ...'";
    echo
    echo "example:";
    echo "command 09397818089 3000458089 'how are you today?'";
    exit
}

# if there were not enough argument print help and eixt
if [[ $1 == "" || $2 == "" || $3 == "" ]]; then
    _help_
fi

# assign used entered info
TO="$1" # Should contain the value of {ALERT.SENDTO}
FROM="$2" # Should contain your Ghasedak phone number
TEXT="$3" # Should container the value of {ALERT.MESSAGE} or {ALERT.SUBJECT}

# two log file names
SEND_LOG_FILE='ghasedak.send.log';
DELIVER_LOG_FILE='ghasedak.deliver.log';

# if they do not exist, creating them
touch $SEND_LOG_FILE $DELIVER_LOG_FILE;

# could lines for send.log
LINE_NUMBER=$(wc -l $SEND_LOG_FILE | grep -o '^[[:digit:]]\+');
if [[ $LINE_NUMBER == "" ]]; then
    LINE_NUMBER=1;
else
    LINE_NUMBER=$((++LINE_NUMBER));
fi

# log the line-number, then the info
echo -n "$LINE_NUMBER " |& tee -a $SEND_LOG_FILE;
echo "$(date) ${TEXT} ${FROM} ${TO}" |& tee -a $SEND_LOG_FILE;

# send the message using curl
curl -sL -X POST "http://api.ghasedak.io/v2/sms/send/simple" \
	-H "apikey: ${API_KEY}" \
	-H 'cache-control: no-cache' \
	-H 'content-type: application/x-www-form-urlencoded' \
	-d "message=${TEXT}&linenumber=${FROM}&receptor=${TO}" |& tee -a $DELIVER_LOG_FILE

# end a new line to deliver log
echo;
echo "" >> $DELIVER_LOG_FILE;
