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

if [ "$SYSTEM" == "$SYSTEM_ANDROID" ]; then
curl -X POST \
  https://mg.snapplog.com/list/upload \
  -H "content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW" \
  -F version=3.0.2 \
  -F "content=$COMMIT_MESSAGE" \
  -F mode=1 \
  -F system=$SYSTEM_ANDROID_CODE \
  -F "updateMode=0,1" \
  -F "platformId=$PLATFORM_ID" \
  -F "apk=@$APPCENTER_OUTPUT_DIRECTORY/app-$FLAVOR_NAME-release.apk" \
  -F token=$TOKEN
fi