#!/usr/bin/env bash

CWD=`pwd`

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_DIR_SINGLE=$(basename "${SCRIPT_DIR}")
SCRIPT_FILE=$(basename "${BASH_SOURCE[0]}")

cd $SCRIPT_DIR
cd ..
TEMP_DIR_EXT="$SCRIPT_DIR-temp"
TEMP_DIR_EXT_SINGLE="$SCRIPT_DIR_SINGLE-temp"
mkdir $TEMP_DIR_EXT_SINGLE

cd ..
cd $SCRIPT_DIR
mv .git $TEMP_DIR_EXT
mv $SCRIPT_FILE $TEMP_DIR_EXT

OUTPUT_PATH=$SCRIPT_DIR

cd ../CiderCSSKit
swift package \
	--allow-writing-to-directory $OUTPUT_PATH \
	generate-documentation \
	--target CiderCSSKit \
	--disable-indexing \
	--transform-for-static-hosting \
	--hosting-base-path CiderCSSKit \
	--output-path $OUTPUT_PATH

cd $SCRIPT_DIR
mv $TEMP_DIR_EXT/.git .
mv $TEMP_DIR_EXT/$SCRIPT_FILE .

rmdir $TEMP_DIR_EXT

cd $CWD