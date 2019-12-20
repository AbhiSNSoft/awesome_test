#!/usr/bin/env bash

MGB_UPLOAD_STATUS="Build upload not Requested"
MGB_STATUS_CODE="000"

echo "Uploading started"

MGB_UPLOAD_RESPONSE=$(curl \
-X POST https://mgb.snapplog.com/list/upload \
-H 'content-type: multipart/form-data' \
-F version=3.0.2 -F 'content=test desc' \
-F mode=1 -F system=0 -F 'updateMode=0,1' \
-F platformId=5da69cb85477a3f6ab3f5c51 \
-F token=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ.eyJkYXRhIjp7Im5hbWUiOiJhcHBjZW50ZXIifSwiaWF0IjoxNTc0ODI4NjI5LCJleHAiOjE2MDYzODYyMjl9.W-zPfEUdT2j-YqBE4SO7vnJPFxUQAR9i8YjFufebdwaXzm4siYE-RuV-PsBkqUFQIBvPaLuNa0I-hqHBnpAzJpVKFFCfz1h_-LtDyadbQIemHYS2DCgQ_SDzcrEsYryijBzP3Efg3MWvCooGTMkUoy_60cgaHxMrEZ7s1Gq2lYc \
-F apk=@/Users/snsoft/Downloads/app-jbl-release.apk | \
jq --raw-output 'if .status == 200 then {status} else . end' )





echo "MGB_UPLOAD_RESPONSE=$MGB_UPLOAD_RESPONSE"

MGB_STATUS_CODE=$(jq '.status' <<< "$MGB_UPLOAD_RESPONSE" )
# MGB_STATUS_MESSAGE=$(jq 'if .status == 200 then "Upload Succeeded." else "Upload failed. \nMESSAGE: "+.message+"\nSTACK: "+.stack end' <<< "$MGB_UPLOAD_RESPONSE" )

echo "MGB_STATUS_CODE=$MGB_STATUS_CODE"

if [ "$MGB_STATUS_CODE" == "200" ];
then
    MGB_UPLOAD_STATUS="Build upload Succeeded"
else
    MGB_UPLOAD_STATUS="Build upload failed"
    MGB_ERROR_MESSAGE=$(jq '.message' <<< "$MGB_UPLOAD_RESPONSE" )
    MGB_ERROR_STACK=$(jq '.stack' <<< "$MGB_UPLOAD_RESPONSE" )
    MGB_ERROR_NAME=$(jq '.name' <<< "$MGB_UPLOAD_RESPONSE" )

    echo "MGB_ERROR_NAME=$MGB_ERROR_NAME"
    echo "MGB_ERROR_MESSAGE=$MGB_ERROR_MESSAGE"
    echo "MGB_ERROR_STACK=$MGB_ERROR_STACK"
fi

echo "MGB_UPLOAD_STATUS: $MGB_UPLOAD_STATUS"
# echo "MGB_STATUS_MESSAGE=$MGB_STATUS_MESSAGE"

# This is to get the Build Details so we could pass it as part of the Email Body
build_url="BUILD OUTPUT: \n
https://appcenter.ms/users/
\n"
# Address to send email
TO_ADDRESS="abhinay@snsoft.my"
# A sample Subject Title 
SUBJECT="AppCenter Build !"
# Content of the Email on Build-Success.

# UPLOAD Build-Success.
SUCCESS_UPLOAD_BODY="Success! Your build completed and build upload Succeeded!\n\n"

# UPLOAD Build-Failure.
FAIL_UPLOAD_BODY="Failed! Your build completed successfully but build upload Failed!\n\n
UPLOAD_ERROR_NAME=$MGB_ERROR_NAME\n
UPLOAD_ERROR_MESSAGE=$MGB_ERROR_MESSAGE\n
UPLOAD_ERROR_STACK=$MGB_ERROR_STACK\n"

BODY_DISCLAIMER="\n*************************************************************************************************\n
Disclaimer: This mail is auto generated do not reply."
# Content of the Email on Build-Failure.
FAILURE_BODY="Sorry! Your AppCenter Build failed. Please review the logs and try again.\n\n"


if ["$MGB_UPLOAD_STATUS" == "Build upload not Requested" ];
then
    echo -e ${FAIL_UPLOAD_BODY} ${build_url} ${BODY_DISCLAIMER}   | mail -s "$MGB_PLATFORM_NAME $MGB_SYSTEM_OS($APPCENTER_BUILD_ID) ${SUBJECT}" ${TO_ADDRESS}
else
    if [ "$MGB_STATUS_CODE" == "200" ];
    then
        echo -e ${FAIL_UPLOAD_BODY} ${build_url} ${BODY_DISCLAIMER}   | mail -s "$MGB_PLATFORM_NAME $MGB_SYSTEM_OS($APPCENTER_BUILD_ID) ${SUBJECT}" ${TO_ADDRESS}
    else
        echo -e ${FAIL_UPLOAD_BODY} ${build_url} ${BODY_DISCLAIMER}   | mail -s "$MGB_PLATFORM_NAME $MGB_SYSTEM_OS($APPCENTER_BUILD_ID) ${SUBJECT}" ${TO_ADDRESS}
    fi
fi

echo "Uploading finished"