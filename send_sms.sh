#!/usr/bin/bash

SERVER=192.168.8.1
USERNAME="admin"
PASSWORD="dr1NMd9g"

sha256base64 () {
	hash=`echo -n $1 | sha256sum | cut -d " " -f 1 | tr -d "\n" | base64 -w 0`
}

phone=$1
content=$2
length=${#content}
date=`date "+%F %H:%M:%S"`

info=`curl -s http://$SERVER/api/webserver/SesTokInfo`

session=`echo $info | xmllint --xpath "/response/SesInfo/text()" -` 
token=`echo $info | xmllint --xpath "/response/TokInfo/text()" -`

sha256base64 "$PASSWORD"
sha256base64 "$USERNAME$hash$token"

login="<request><Username>$USERNAME</Username><Password>$hash</Password><password_type>4</password_type></request>"
login_response=`curl -i -s -b "SessionID=$session" -H "__RequestVerificationToken: $token" -d "$login" http://$SERVER/api/user/login`

session=`echo "$login_response" | grep -o "SessionID=[0-9a-zA-Z]*" | cut -d "=" -f 2`
token=`echo "$login_response" | grep -o "__RequestVerificationTokenone: [0-9a-zA-Z]*" | cut -d " " -f 2`

sms="<request><Index>-1</Index><Phones><Phone>$phone</Phone></Phones><Content>$content</Content><Length>$length</Length><Reserved>1</Reserved><Date>$date</Date></request>"
sms_response=`curl -s -b "SessionID=$session" -H "__RequestVerificationToken: $token" -d "$sms" http://$SERVER/api/sms/send-sms`

result=`echo $sms_response | xmllint --xpath "/response/text()" -`

if [[ $result == "OK" ]]
then
	exit 0
else
	exit 1
fi
