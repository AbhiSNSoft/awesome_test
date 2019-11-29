#!/usr/bin/env bash

# Deploy to mg.snapplog.com

# Get the message of the last commit using Git
COMMIT_MESSAGE=$(git log -1 HEAD --pretty=format:%s)

# Update your ORG name and APP name
ORG=abhisnsoft
APP=$APP_NAME

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
build_url=https://appcenter.ms/orgs/$ORG/apps/$APP/build/branches/$APPCENTER_BRANCH/builds/$APPCENTER_BUILD_ID
# Address to send email
TO_ADDRESS="abhinay@snsoft.my"
# A sample Subject Title 
SUBJECT="AppCenter Build"
# Content of the Email on Build-Success.
SUCCESS_BODY="Success! Your build($APPCENTER_BUILD_ID) completed successfully!\n\n"
# Content of the Email on Build-Failure.
FAILURE_BODY="Sorry! Your AppCenter Build($APPCENTER_BUILD_ID) failed. Please review the logs and try again.\n\n"
#If Agent Job Build Status is successful, Send the email, if not send a failure email.``

OS_ANDROID=android
OS_IOS=ios

echo "BUILD_SOURCEVERSION: $BUILD_SOURCEVERSION"

echo "APPCENTER_SOURCE_DIRECTORY: " $APPCENTER_SOURCE_DIRECTORY
echo "APPCENTER_OUTPUT_DIRECTORY: " $APPCENTER_OUTPUT_DIRECTORY

echo "OS_ANDROID: " $OS_ANDROID
echo "OS_IOS: " $OS_IOS

if [ "$AGENT_JOBSTATUS" == "Succeeded" ]; 
    then
        echo "OS detected: " $SYSTEM_OS
        # ANDROID - upload .apk file to Manager
        if [ "$SYSTEM_OS" == "$OS_ANDROID" ]; 
            then
            echo "$SYSTEM_OS uploading stated"
            curl \
            -X POST https://mgb.snapplog.com/list/upload \
            -H "content-type: multipart/form-data" \
            -F "version=$APP_VERSION" \
            -F "content=$COMMIT_MESSAGE -- uploaded from App Center($PLATFORM_NAME, Build id:$APPCENTER_BUILD_ID)" \
            -F "mode=1" \
            -F "system=0" \
            -F "updateMode=0,1" \
            -F "platformId=$PLATFORM_ID" \
            -F "apk=@$APPCENTER_OUTPUT_DIRECTORY/app-$PLATFORM_NAME-release.apk" \
            -F "token=$MGB_TOKEN"
            echo "$SYSTEM_OS uploading finished"
        fi
        
        # IOS - upload .ipa file to Manager
        if [ "$SYSTEM_OS" == "$OS_IOS" ]; 
            then
            echo "$SYSTEM_OS uploading stated"
            curl \
            -X POST https://mgb.snapplog.com/list/upload \
            -H "content-type: multipart/form-data" \
            -F "version=$APP_VERSION" \
            -F "content=$COMMIT_MESSAGE -- uploaded from App Center($PLATFORM_NAME, Build id:$APPCENTER_BUILD_ID)" \
            -F "mode=1" \
            -F "system=1" \
            -F "updateMode=0,1" \
            -F "platformId=$PLATFORM_ID" \
            -F "apk=@$APPCENTER_OUTPUT_DIRECTORY/$PLATFORM_NAME.ipa" \
            -F "token=$MGB_TOKEN"
            echo "$SYSTEM_OS uploading finished"
        fi

        echo "Build Success!"
        echo -e ${SUCCESS_BODY} ${build_url} | mail -s "$PLATFORM_NAME ${SUBJECT} - Success!" ${TO_ADDRESS}
        echo "success mail sent"

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
    	
    else
        echo "Build Failed!"
        echo -e ${FAILURE_BODY} ${build_url} | mail -s "$PLATFORM_NAME ${SUBJECT} - Failed!" ${TO_ADDRESS}
        echo "failure mail sent"
fi