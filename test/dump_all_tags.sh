#!/usr/bin/env bash

pac=$1
if [ -z "$pac" ]
then
	echo "syntaxe : $0 package"
	exit
fi

liste_tags=$( rpm --querytags | sort )
for tag in $liste_tags
do
	rpm -q --queryformat "$tag [ %{$tag} \n]" $pac
done
