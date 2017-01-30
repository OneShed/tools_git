#!/bin/bash

#/vobs/CDIRECT_DDL -> CDIRECT_DDL /vobs/CDIRECT_DDL
for vob in $(cat /tmp/vobs); do result=$(echo $vob | sed 's/^.\{6\}//'); echo "$result $vob"; done
