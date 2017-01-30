#!/bin/bash
# Usage: $0 [<appl>] [<vob>] [<env>] [<build script>]
# unix non built:
# 	 $0 T2S_I_GUI /vobs/T2S-I-GUI UNIX t2si_gui.txt
#	 $0 AMADEUS_DDL /vobs/AMADEUS_DDL 

set -e
set -u
set -x

PATH=/bin:/usr/bin

PCKG_LIST=/local/git/scm/pckg_list
BUILD_SCRIPTS=/local/git/scm/build_scripts
APPL=$1
VOB=$2
ENV="${3:-UNIX}"
BS="${4:-none}"
PEL=${APPL}-${ENV}.xml

PEL_DIR="${PCKG_LIST}/${APPL}-${ENV}"

if [[ ${BS} != 'none' ]]; then 
	 BS="/vobs/CFM/tools/BUILD_SCRIPTS/${BS}"
fi

mkdir -p $PEL_DIR
cp /vobs/CFM/tools/PCKG_LIST/$PEL $PEL_DIR
chmod 755 $PEL_DIR/$PEL
cd $PEL_DIR
git init .
git add .
sed -i 's/PckgElmnt.dtd/..\/PckgElmnt.dtd/g' $PEL_DIR/$PEL 

VOB=$(echo $VOB | sed 's/\//\\\//g')

# use vim substitute
eval "ex $PEL_DIR/$PEL <<EOF
:%s/$VOB//g
:x
EOF"

git commit -a -m"Initial commit"
echo "Package element list of $APPL-$ENV" > $PEL_DIR/.git/description

if [[ ${BS} == 'none' ]]; then
	git commit -a -m"Initial commit"
	echo "Build script of $APPL-$ENV" > $BS_DIR/.git/description
	echo "All done"
	exit 0
fi

BS_DIR="${BUILD_SCRIPTS}/${APPL}-${ENV}"

mkdir -p $BS_DIR
cp $BS $BS_DIR
chmod -R 755 $BS_DIR
cd $BS_DIR
git init .
git add .
git commit -a -m"Initial commit"
echo "Build script of $APPL-$ENV" > $BS_DIR/.git/description

echo "All done"
echo
