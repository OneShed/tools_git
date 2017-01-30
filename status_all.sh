#!/bin/bash

for repo in $(ls); do if [[ $repo != 'PckgElmnt.dtd' && ! ${repo} =~ ".sh" ]]; then echo $repo; cd $repo; git status; cd ..;fi; done
