#!/usr/bin/env bash

CWD=`pwd`

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR

OUTPUT_PATH="$SCRIPT_DIR-documentation/docs"

swift package \
	--allow-writing-to-directory $OUTPUT_PATH \
	generate-documentation \
	--target CiderCSSKit \
	--disable-indexing \
	--transform-for-static-hosting \
	--hosting-base-path CiderCSSKit \
	--output-path $OUTPUT_PATH

if [[ "--push" == $1 ]]; then
	echo ""
	echo "Committing and pushing to repository..."

	cd $OUTPUT_PATH

	git add --all
	git commit -m "📝 Updated documentation"
	git push
else
	echo ""
	echo "NOTE: Use --push attribute if you want to push changes to the documentation immediately"
fi

cd $CWD