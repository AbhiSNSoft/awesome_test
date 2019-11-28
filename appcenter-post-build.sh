#!/usr/bin/env bash

# Publish the changes using CodePush and deploy to mg.snapplog.com

ENVIRONMENT=Development
APP_NAME=OrganizationName/MyApp-iOS
APP_PATH=myAppDebug.ipa
APP_CENTER_TOKEN=""

# HockeyApp-iOS-Dev
HOCKEY_APP_ID=""
HOCKEY_TOKEN=""

# Get the message of the last commit using Git
COMMIT_MESSAGE=$(git log -1 HEAD --pretty=format:%s)

# if [ "$APPCENTER_BRANCH" == "master" ]; then
#     ENVIRONMENT=Production
#     APP_PATH=myApp.ipa
#     # HockeyApp-iOS-Prod
#     HOCKEY_APP_ID=""
# fi

# if [[ -z "$APPCENTER_XCODE_PROJECT" ]]; then
#     APP_NAME=OrganizationName/MyApp-Android
#     APP_PATH=app-debug.apk
#     # HockeyApp-Android-Dev
#     HOCKEY_APP_ID=""

#     if [ "$APPCENTER_BRANCH" == "master" ]; then
#         APP_PATH=app-release.apk
#         # HockeyApp-Android-Prod
#         HOCKEY_APP_ID=""
#     fi
# fi

# echo "**************** PUBLISH CHANGES WITH CODEPUSH ******************"
# echo "APP NAME                => $APP_NAME"
# echo "CURRENT ENVIRONMENT     => $ENVIRONMENT"
# echo "SELECTED RN PACKAGE     => $APPCENTER_REACTNATIVE_PACKAGE"
# echo "OUTPUT DIRECTORY        => $APPCENTER_OUTPUT_DIRECTORY"
# if [[ -z "$APPCENTER_XCODE_PROJECT" ]]; then
#     echo "SELECTED ANDROID MODULE  => $APPCENTER_ANDROID_MODULE"
#     echo "SELECTED ANDROID VARIANT => $APPCENTER_ANDROID_VARIANT"
# else
#     echo "SELECTED XCODE PROJECT   => $APPCENTER_XCODE_PROJECT"
#     echo "SELECTED XCODE SCHEME    => $APPCENTER_XCODE_SCHEME"
# fi

# appcenter codepush release-react -a "$APP_NAME" -m --description "$COMMIT_MESSAGE" -d "$ENVIRONMENT" --token "$APP_CENTER_TOKEN"

# curl \
#     -F "status=2" \
#     -F "notify=1" \
#     -F "notes=$COMMIT_MESSAGE" \
#     -F "notes_type=0" \
#     -F "ipa=@$APPCENTER_OUTPUT_DIRECTORY/$APP_PATH" \
#     -H "X-HockeyAppToken: $HOCKEY_TOKEN" \
#     https://rink.hockeyapp.net/api/2/apps/$HOCKEY_APP_ID/app_versions/upload

# $SYSTEM 
#0=android
#1=ios
SYSTEM_ANDROID=android
SYSTEM_IOS=ios
SYSTEM_ANDROID_CODE=0
SYSTEM_IOS_CODE=1

echo "APPCENTER_SOURCE_DIRECTORY: " $APPCENTER_SOURCE_DIRECTORY
echo "APPCENTER_OUTPUT_DIRECTORY: " $APPCENTER_OUTPUT_DIRECTORY
echo "FLAVOR_NAME: " $FLAVOR_NAME
echo "SYSTEM: " $SYSTEM
echo "SYSTEM_ANDROID: " $SYSTEM_ANDROID


if [ "$AGENT_JOBSTATUS" == "Succeeded" ]; then
    HOCKEYAPP_API_TOKEN={API_Token}
    HOCKEYAPP_APP_ID={APP_ID}

    curl \
    -X POST https://mgb.snapplog.com/list/upload \
    -H "content-type: multipart/form-data" \
    -F "version=3.0.2" \
    -F "content=test desc" \
    -F "mode=1" \
    -F "system=0" \
    -F "updateMode=0,1" \
    -F "platformId=5da69cb85477a3f6ab3f5c51" \
    -F "apk=@$APPCENTER_OUTPUT_DIRECTORY/app-$FLAVOR_NAME-release.apk" \
    -F "token=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7Im5hbWUiOiJhcHBjZW50ZXIifSwiaWF0IjoxNTc0ODI4NjI5LCJleHAiOjE2MDYzODYyMjl9.W-zPfEUdT2j-YqBE4SO7vnJPFxUQAR9i8YjFufebdwaXzm4siYE-RuV-PsBkqUFQIBvPaLuNa0I-hqHBnpAzJpVKFFCfz1h_-LtDyadbQIemHYS2DCgQ_SDzcrEsYryijBzP3Efg3MWvCooGTMkUoy_60cgaHxMrEZ7s1Gq2lYc"

    echo "Current branch is $APPCENTER_BRANCH"
fi

# if [ "$SYSTEM" == "$SYSTEM_ANDROID" ]; then
#   curl -X POST https://mgb.snapplog.com/list/upload \
#   -H 'content-type: multipart/form-data' \
#   -F version=3.0.2 \
#    -F 'content=test desc' \
#   -F mode=1 \
#   -F system=0 \
#   -F 'updateMode=0,1' \
#   -F platformId=5da69cb85477a3f6ab3f5c51 \
#   -F apk=@$APPCENTER_OUTPUT_DIRECTORY/app-$FLAVOR_NAME-release.apk \
#   -F token=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7Im5hbWUiOiJhcHBjZW50ZXIifSwiaWF0IjoxNTc0ODI4NjI5LCJleHAiOjE2MDYzODYyMjl9.W-zPfEUdT2j-YqBE4SO7vnJPFxUQAR9i8YjFufebdwaXzm4siYE-RuV-PsBkqUFQIBvPaLuNa0I-hqHBnpAzJpVKFFCfz1h_-LtDyadbQIemHYS2DCgQ_SDzcrEsYryijBzP3Efg3MWvCooGTMkUoy_60cgaHxMrEZ7s1Gq2lYc
# fi

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

# Update your ORG name and APP name
ORG=abhisnsoft
APP=awesome-test-android
# This is to get the Build Details so we could pass it as part of the Email Body
build_url=https://appcenter.ms/orgs/$ORG/apps/$APP/build/branches/$APPCENTER_BRANCH/builds/$APPCENTER_BUILD_ID
# Address to send email
TO_ADDRESS="abhinay@snsoft.my"
# A sample Subject Title 
SUBJECT="AppCenter Build"
# Content of the Email on Build-Success.
SUCCESS_BODY="Success! Your build completed successfully!\n\n"
# Content of the Email on Build-Failure.
FAILURE_BODY="Sorry! Your AppCenter Build failed. Please review the logs and try again.\n\n"
#If Agent Job Build Status is successful, Send the email, if not send a failure email.``
if [ "$AGENT_JOBSTATUS" == "Succeeded" ];
then
	echo "Build Success!"
	echo -e ${SUCCESS_BODY} ${build_url} | uuencode $APPCENTER_OUTPUT_DIRECTORY/app-$FLAVOR_NAME-release.apk app-$FLAVOR_NAME-release.apk | mail -s "${SUBJECT} - Success!" ${TO_ADDRESS}
	echo "success mail sent"
    echo $TEST_VARIABLE
	echo "APPCENTER_BUILD_ID: " $APPCENTER_BUILD_ID
	echo "APPCENTER_BRANCH: " $APPCENTER_BRANCH
	echo "APPCENTER_SOURCE_DIRECTORY: " $APPCENTER_SOURCE_DIRECTORY
	echo "APPCENTER_OUTPUT_DIRECTORY: " $APPCENTER_OUTPUT_DIRECTORY
	echo "APPCENTER_TRIGGER: " $APPCENTER_TRIGGER
#	echo "APPCENTER_XCODE_PROJECT: " $APPCENTER_XCODE_PROJECT
#	echo "APPCENTER_XCODE_SCHEME: " $APPCENTER_XCODE_SCHEME
	echo "APPCENTER_ANDROID_VARIANT: " $APPCENTER_ANDROID_VARIANT
	echo "APPCENTER_ANDROID_MODULE: " $APPCENTER_ANDROID_MODULE
	echo "APPCENTER_REACTNATIVE_PACKAGE: " $APPCENTER_REACTNATIVE_PACKAGE
else
	echo "Build Failed!"
	echo -e ${FAILURE_BODY} ${build_url} | mail -s "${SUBJECT} - Failed!" ${TO_ADDRESS}
	echo "failure mail sent"
fi