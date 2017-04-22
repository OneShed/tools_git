#!/bin/bash
#
# edit file content using vim substitute

set -e
set -u 
set -x
file=$1

eval "ex $file <<EOF
%s/\$\{_CYCLE}/\$\{_CYCLE} - \$\{_VERSION}/g
:x
EOF"
