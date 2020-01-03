#!/bin/sh

echo "[!] - Entrypoint has started";

echo "[!] - installing aws cli";
pip install awscli
aws s3 help


# Should we go up a dir before exiting?
die(){
	if [ -n "$JEKYLL_ROOT" ]; then
		cd ../
	fi
}

# Where should we try to do all of this?
#if [ -z "$JEKYLL_ROOT" ]; then
#  echo "[!] - JEKYLL_ROOT is not set. Going to try and build the root dir."
#else
#	if [ ! -d "${JEKYLL_ROOT}" ]; then
#		echo "[!!!!] - ${JEKYLL_ROOT} not found, exiting!"
#		exit 1;
#	fi
#
#  	cd "${JEKYLL_ROOT}";
#
#fi

# Whats the gemfile called?
if [ -z "$GEMFILE" ]; then
	echo "[!] - Gemfile not defined; defaulting to GemFile";
	GEMFILE="Gemfile";
fi
if [ ! -f "$GEMFILE" ]; then
	echo "[!!!!] - ${GEMFILE} not found - exiting";
	die
	exit 1
fi


# Should we delete the gemlock when building?
if [ -n "$REMOVE_GEMLOCK" ] && [ "$REMOVE_GEMLOCK" = true ]; then
	echo "[!] - Removing Gemlock."
	rm Gemfile.lock > /dev/null 2>&1
fi


#echo '[!] - Installing Gem Bundle'
#bundle install

#echo -n '[!] - Jekyll Version: '
#bundle list | grep "jekyll ("

if [ -n "$DELETE_BEFORE_BUILD" ]; then
	echo -n "[!] - Deleting ${DELETE_BEFORE_BUILD}"
	rm -rf ${DELETE_BEFORE_BUILD};
fi

mkdir /github /github/workspace /github/workspace/.jekyll-cache /github/workspace/_site
chmod -R 777 /github

echo '[!] - Building '
jekyll build

echo '[!] - uploading to s3'

aws s3 sync /github/workspace/_site s3://${AWS_S3_BUCKET}/foo/

echo '[!] - EntryPoint has finished.'
die
exit

