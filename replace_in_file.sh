#!/bin/bash
#
# edit file content using sed
#
# Usage for batch replacement in config.xml
# for f in $(find <jenkins_jobs_folder> -name 'config.xml'); do
# ./replace_in_file.sh $f; done

file=$1

#old="<template>\${_CYCLE} - \${_VERSION}<\/template>"
#new="<template>\${_CYCLE} - \${_VERSION} - \${_EEPR}<\/template>"
old=" - \${_EEPR}<\/template>"
new=" - \${_EEPRID}<\/template>"
sed -i "s/$old/$new/" $1
