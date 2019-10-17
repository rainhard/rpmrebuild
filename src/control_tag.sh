#!/usr/bin/env bash
# to be used when reveive a bug report to check tags against popt

# edit report and remove all but rpm tags
# get rpm tags from bug report
rpm_tags=$( cat bugreport )

# get tags used in rpmrebuild
# rpmrebuild_popt should follow a strict syntaxe
# "%|" begin a test line
# tr command remove all not alpha characters
# the "dummy" query should be filtered too
rpmrebuild_tags=$( ./rpmrebuild_extract_tags.sh rpmrebuild_rpmqf.src )

# check for all rpmrebuild tags
errors=0
for tag in $rpmrebuild_tags
do
	ok=''
	# if it exists in rpm tags
	for rpm_tag in $rpm_tags
	do
		if [ "$tag" = "$rpm_tag" ]
		then
			# ok : we find it
			ok='y'
			break
		fi
	done
	if [ -z "$ok" ]
	then
		echo "(CheckTags) can not find rpm tag $tag"
		let errors="$errors + 1"
	fi
done
