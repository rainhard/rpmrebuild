#!/bin/bash
# E Gerbier 2018-09-21
# build an optional tag file
# using all registered query tags file

rm optional_tags*

# get optional tags for each distribution
for f in querytags*
do
	./unavailable_tags.sh $f > optional_tags.$f
done

# the result is the merge of all individuals files
cat optional_tags.* | sort -u > optional_tags

# merge with used file
meld optional_tags ../src/optional_tags.cfg

# rm optional_tags.*
