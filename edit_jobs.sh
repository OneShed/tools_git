#!/bin/bash
#
# edit file content using vim substitute
file=$1

param="<hudson.model.StringParameterDefinition><name>_sire<\/name><description>SIRE number (only for PROD EPRs)<\/description><defaultValue><\/defaultValue><\/hudson.model.StringParameterDefinition>"

eval "ex $file <<EOF
:%s/<\/parameterDefinitions>/$param<\/parameterDefinitions>/g
:x
EOF"
