#!/usr/bin/env bash

CWD=`pwd`

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR

OUTPUT_PATH="$SCRIPT_DIR/docs"

cd ../CiderCSSKit
swift package \
	--allow-writing-to-directory $OUTPUT_PATH \
	generate-documentation \
	--target CiderCSSKit \
	--disable-indexing \
	--transform-for-static-hosting \
	--hosting-base-path CiderCSSKit \
	--output-path $OUTPUT_PATH

cd $CWD