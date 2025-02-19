#!/usr/bin/env bash
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
ORG=AndroidOrg
APP=AndrXam
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