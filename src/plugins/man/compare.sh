#!/bin/sh

# comparison of the 2 french docs
for f in fr_FR/*
do
	ff=$( basename $f)
	vimdiff $f fr_FR.UTF-8/$ff
done
