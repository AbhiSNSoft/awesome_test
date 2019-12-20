#!/usr/bin/env bash

# Deploy to mg.snapplog.com

# Get the message of the last commit using Git
COMMIT_MESSAGE=$(git log -1 HEAD --pretty=format:%s)

# Update your ORG name and APP name
ORG=abhisnsoft
APP=$MGB_APP_NAME

#
# Send a build notification over Email on Success/Failure of AppCenter Builds.
#
# Ensure you exclude the Sender Email Address from your Mail Spam Filters,   
# or it will go to the Junk/Spam Folder.
# The 'from' email looks like this, vsts <vsts@Mac-n.local> where n could be {1,2,3...}
# Create Rules/Filters to route to Inbox based on Subject/Sender.
#
# Modify the ORG, APP, TO_ADDRESS, SUBJECT, SUCCESS_BODY, FAILURE_BODY as required. 
#
# Add it as a Post-Build Script (appcenter-post-build.sh)
# Configure your AppCenter build(s) to ensure the Build Script is picked.
#
# Uses UNIX LF EOL format. 
#
# Contributed by Manigandan Balachandran
#
# This is to get the Build Details so we could pass it as part of the Email Body
build_url="BUILD OUTPUT LOGS: \n
https://appcenter.ms/users/$ORG/apps/$APP/build/branches/$APPCENTER_BRANCH/builds/$APPCENTER_BUILD_ID"
# Address to send email
TO_ADDRESS="abhinay@snsoft.my"
# Email disclaimer
BODY_DISCLAIMER="\n*************************************************************************************************\n
Disclaimer: This mail is auto generated do not reply."

OS_ANDROID=android
OS_IOS=ios

# MGB_BUILD_MODE
# 0 => Staging
# 1 => Production (Default)
MGB_BUILD_MODE=1

# MGB_BUILD_UPLOAD
# true => Upload build
# false => Don't upload build (Default)
MGB_BUILD_UPLOAD=false

MGB_BUILD_MODE_STAGING="build-d"
MGB_BUILD_MODE_PRERELEASE="build-p"


echo "BUILD_SOURCEVERSION: $BUILD_SOURCEVERSION"
echo "APPCENTER_BUILD_ID: " $APPCENTER_BUILD_ID
echo "APPCENTER_BRANCH: " $APPCENTER_BRANCH
echo "APPCENTER_SOURCE_DIRECTORY: " $APPCENTER_SOURCE_DIRECTORY
echo "APPCENTER_OUTPUT_DIRECTORY: " $APPCENTER_OUTPUT_DIRECTORY
echo "APPCENTER_TRIGGER: " $APPCENTER_TRIGGER
echo "APPCENTER_XCODE_PROJECT: " $APPCENTER_XCODE_PROJECT
echo "APPCENTER_XCODE_SCHEME: " $APPCENTER_XCODE_SCHEME
echo "APPCENTER_ANDROID_VARIANT: " $APPCENTER_ANDROID_VARIANT
echo "APPCENTER_ANDROID_MODULE: " $APPCENTER_ANDROID_MODULE
echo "APPCENTER_REACTNATIVE_PACKAGE: " $APPCENTER_REACTNATIVE_PACKAGE
echo "COMMIT_MESSAGE: $COMMIT_MESSAGE"

# If Agent Job Build Status is successful, Send the email, if not send a failure email.
if [ "$AGENT_JOBSTATUS" == "Succeeded" ]; 
    then
    echo "Build Success!"

    # Upload build to Manager if branch is production(rn0.6_prod)
	if [ "$APPCENTER_BRANCH" == "rn0.6_prod" ];
        then
        echo "production branch $APPCENTER_BRANCH"
        MGB_BUILD_UPLOAD=true
        MGB_BUILD_MODE=1
    # Upload build to Manager if commit message contains [build-d]
    elif [[ "$COMMIT_MESSAGE" == *$MGB_BUILD_MODE_STAGING* ]]; 
        then
        echo "build-d staging"
        MGB_BUILD_UPLOAD=true
        MGB_BUILD_MODE=0
    # Upload build to Manager if commit message contains [build-p]
    elif [[ "$COMMIT_MESSAGE" == *$MGB_BUILD_MODE_PRERELEASE* ]]; 
        then
        echo "build-p pre-release"
        MGB_BUILD_UPLOAD=true
        MGB_BUILD_MODE=1
    # Don't upload build to Manager
    else
        echo "Skip upload"
        MGB_BUILD_UPLOAD=false
        MGB_BUILD_MODE=0
    fi

    echo "MGB_BUILD_UPLOAD: $MGB_BUILD_UPLOAD"
    echo "MGB_BUILD_MODE: $MGB_BUILD_MODE"
    if [ "$MGB_BUILD_UPLOAD" == "true" ]; 
        then
        echo "OS detected: " $MGB_SYSTEM_OS
        # ANDROID - upload .apk file to Manager
        if [ "$MGB_SYSTEM_OS" == "$OS_ANDROID" ]; 
            then
            echo "$MGB_SYSTEM_OS uploading started"
            
            MGB_UPLOAD_RESPONSE=$(curl \
            -X POST https://mgb.snapplog.com/list/upload \
            -H "content-type: multipart/form-data" \
            -F "version=$MGB_APP_VERSION" \
            -F "content=$COMMIT_MESSAGE -- uploaded from App Center($MGB_PLATFORM_NAME, Build id:$APPCENTER_BUILD_ID)" \
            -F "mode=$MGB_BUILD_MODE" \
            -F "system=0" \
            -F "updateMode=0,1" \
            -F "platformId=$MGB_PLATFORM_ID" \
            -F "apk=@$APPCENTER_OUTPUT_DIRECTORY/app-$MGB_PLATFORM_NAME-release.apk" \
            -F "token=$MGB_TOKEN" | \
            jq --raw-output 'if .status == 200 then {status} else . end' )

            echo "$MGB_SYSTEM_OS uploading finished"
        fi
        
        # IOS - upload .ipa file to Manager
        if [ "$MGB_SYSTEM_OS" == "$OS_IOS" ]; 
            then
            echo "$MGB_SYSTEM_OS uploading started"
            MGB_UPLOAD_RESPONSE=$(curl \
            -X POST https://mgb.snapplog.com/list/upload \
            -H "content-type: multipart/form-data" \
            -F "version=$MGB_APP_VERSION" \
            -F "content=$COMMIT_MESSAGE -- uploaded from App Center($MGB_PLATFORM_NAME, Build id:$APPCENTER_BUILD_ID)" \
            -F "mode=$MGB_BUILD_MODE" \
            -F "system=1" \
            -F "updateMode=0,1" \
            -F "platformId=$MGB_PLATFORM_ID" \
            -F "apk=@$APPCENTER_OUTPUT_DIRECTORY/$MGB_PLATFORM_NAME.ipa" \
            -F "token=$MGB_TOKEN" | \
            jq --raw-output 'if .status == 200 then {status} else . end' )
            
            echo "$MGB_SYSTEM_OS uploading finished"
        fi

        echo "MGB_STATUS_CODE=$MGB_STATUS_CODE"
        # UPLOAD Build-Success.
        if [ "$MGB_STATUS_CODE" == "200" ];
            then
            echo "MGB_UPLOAD_STATUS: Build upload Succeeded"
            
            SUBJECT="✅AppCenter Build $AGENT_JOBSTATUS and build upload Succeeded!"
            SUCCESS_BODY="✅Success! $MGB_PLATFORM_NAME build($APPCENTER_BUILD_ID) completed successfully and build upload Succeeded!\n\n"
        # UPLOAD Build-Failure.
        else
            echo "MGB_UPLOAD_STATUS: Build upload Failed"
            MGB_ERROR_MESSAGE=$(jq '.message' <<< "$MGB_UPLOAD_RESPONSE" )
            MGB_ERROR_STACK=$(jq '.stack' <<< "$MGB_UPLOAD_RESPONSE" )
            MGB_ERROR_NAME=$(jq '.name' <<< "$MGB_UPLOAD_RESPONSE" )

            echo "MGB_ERROR_NAME=$MGB_ERROR_NAME"
            echo "MGB_ERROR_MESSAGE=$MGB_ERROR_MESSAGE"
            echo "MGB_ERROR_STACK=$MGB_ERROR_STACK"
            
            SUBJECT="⛔️AppCenter Build $AGENT_JOBSTATUS and ⚠️build upload Failed!⚠️"
            SUCCESS_BODY="⛔️Failed! $MGB_PLATFORM_NAME build($APPCENTER_BUILD_ID) completed successfully and build upload Failed!\n\n            
            UPLOAD_ERROR_NAME: $MGB_ERROR_NAME\n
            UPLOAD_ERROR_MESSAGE: $MGB_ERROR_MESSAGE\n
            UPLOAD_ERROR_STACK: \n$MGB_ERROR_STACK\n\n"
        fi
    # UPLOAD not requested.
    else
        SUBJECT="✅AppCenter Build $AGENT_JOBSTATUS and build upload not requested!"
        SUCCESS_BODY="✅Success! $MGB_PLATFORM_NAME build($APPCENTER_BUILD_ID) completed successfully and build upload not requested!\n\n"
    fi
    echo -e ${SUCCESS_BODY} ${build_url} ${BODY_DISCLAIMER} | mail -s "$MGB_PLATFORM_NAME $MGB_SYSTEM_OS($APPCENTER_BUILD_ID) ${SUBJECT}" ${TO_ADDRESS}
    echo "success mail sent"
#If Agent Job Build Status is failed, Send the failure email.
else
    echo "Build Failed!"
    
    SUBJECT="⛔️AppCenter Build $AGENT_JOBSTATUS!"
    FAILURE_BODY="⛔️Failed! $MGB_PLATFORM_NAME AppCenter Build($APPCENTER_BUILD_ID) failed. Please review the logs and try again.\n\n"

    echo -e ${FAILURE_BODY} ${build_url} ${BODY_DISCLAIMER} | mail -s "$MGB_PLATFORM_NAME $MGB_SYSTEM_OS($APPCENTER_BUILD_ID) ${SUBJECT}" ${TO_ADDRESS}
    echo "failure mail sent"
fi