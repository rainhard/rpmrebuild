#!/bin/bash
# E Gerbier 2018-09-20
# compare used rpm tags with available tags
# can be used to build the optional_tags file

#################################################
function SearchTag
{
        tag=$1
        for rpm_tag in $RPM_TAGS
        do
                if [ "$tag" = "$rpm_tag" ]
                then
                        # ok : we find it
                        return 0
                        fi
        done
        return 1
}
#################################################
if [ $# -ne 1 ]
then
	echo "syntaxe : $0 rpm_tags"
	exit
fi

liste_tags=$( ../src/rpmrebuild_extract_tags.sh ../src/rpmrebuild_rpmqf.src )

if [ -f "$1" ]
then
	RPM_TAGS=$( cat $1 )
else
	echo "param 1 incorrect"
	exit
fi

for tag in $liste_tags
do
	SearchTag $tag || echo "$tag"
done
