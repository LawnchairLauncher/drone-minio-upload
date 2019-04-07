#!/bin/bash

if [ -z "$MAJOR_MINOR" ]; then
    MAJOR_MINOR="alpha"
fi

if [ -z "$PLUGIN_APK_PATH" ]; then
    PLUGIN_APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
fi

if [ -z "$PLUGIN_MAPPING_PATH" ]; then
    PLUGIN_MAPPING_PATH="app/build/outputs/mapping/debug/mapping.txt"
fi

if [ -z "$PLUGIN_FILENAME" ]; then
    PLUGIN_FILENAME="Lawnchair"
fi

if [ -z "$PLUGIN_UPDATE_VERSION" ]; then
    PLUGIN_UPDATE_VERSION=false
fi

# Create temporary directory for upload
APP_VERSION=$MAJOR_MINOR.$DRONE_BUILD_NUMBER
mkdir -p $APP_VERSION

# Preparing files to upload
APK_FILE=$APP_VERSION/${PLUGIN_FILENAME}-${APP_VERSION}.apk
MD5_CHECKSUM=$APP_VERSION/${PLUGIN_FILENAME}-${APP_VERSION}.md5sum
MAPPING_FILE=$APP_VERSION/proguard-${APP_VERSION}.apk

# Upload apk file
cp $PLUGIN_APK_PATH $APK_FILE
s3-upload.sh $APK_FILE $S3_BUCKET $S3_HOST $S3_KEY $S3_SECRET

# Upload md5 checksum for apk file
md5sum $(readlink -f ${PLUGIN_APK_PATH}) > $MD5_CHECKSUM
s3-upload.sh $MD5_CHECKSUM $S3_BUCKET $S3_HOST $S3_KEY $S3_SECRET

# Check if mapping file exists
if [ -f $PLUGIN_MAPPING_PATH ]; then
    cp $PLUGIN_MAPPING_PATH $MAPPING_FILE
    s3-upload.sh $MAPPING_FILE $S3_BUCKET $S3_HOST $S3_KEY $S3_SECRET
fi

# Update version info
if [ $PLUGIN_UPDATE_VERSION = true ]; then
    echo "{\"major_minor\": \""$MAJOR_MINOR"\", \"travis_build_number\": \""$TRAVIS_BUILD_NUMBER"\", \"app_version\": \""$APP_VERSION"\"}" > version.json
    s3-upload.sh version.json $S3_BUCKET $S3_HOST $S3_KEY $S3_SECRET
fi