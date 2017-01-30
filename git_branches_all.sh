#!/bin/bash

# print 'git branch' on all repos, one line per repo for easier awk-ing.

set -e
set -u

repos=$(find . -maxdepth 1 -type d | egrep -v "\.$" | sed 's/^\.\///')

for repo in ${repos[*]}; do
	cd $repo
	branches=$(git branch | sed 's/\*//' | sed 's/\n//')

	echo "${repo}" ${branches[*]}
	cd ..
done

echo "$(basename $0): All done"
