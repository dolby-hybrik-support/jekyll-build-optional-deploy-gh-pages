#!/bin/sh

echo "[!] - Entrypoint has started for branch ${GHUB_BRANCH}";

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

echo '[!] - Building static site'

# if there is a folder maching the branch name, add a link at the top of the nav
if [ -d "${GHUB_BRANCH}" ]; then
    printf "%s\n%s\n%s\n\n" "- name: ${GHUB_BRANCH}" "  url: ${GHUB_BRANCH}" "  byline: 'the tutorial you wrote for testing'" | cat - _data/tutorials.yml > temp && mv temp _data/tutorials.yml
fi

printf "\nbaseurl: /${GHUB_BRANCH}" >> _config.yml 
jekyll build

echo '[!] - uploading to s3'

echo "removing old branch copy first: ${GHUB_BRANCH}"
aws s3 rm --recursive s3://${AWS_S3_BUCKET}/${GHUB_BRANCH}/

echo "uploading build to branch: $BRANCH"
aws s3 sync --acl public-read /github/workspace/_site s3://${AWS_S3_BUCKET}/${GHUB_BRANCH}/

echo '[!] - EntryPoint has finished.'
die
exit

