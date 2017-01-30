#!/bin/bash
#
# edit file content using vim substitute
file=$1

param="<hudson.plugins.locksandlatches.LockWrapper plugin="locks-and-latches@0.6"><locks><hudson.plugins.locksandlatches.LockWrapper_-LockWaitConfig><name>prodsup_prodscripts_lock<\/name><\/hudson.plugins.locksandlatches.LockWrapper_-LockWaitConfig><\/locks><\/hudson.plugins.locksandlatches.LockWrapper>"

eval "ex $file <<EOF
:%s/<org.jenkinsci.plugins.buildnamesetter.BuildNameSetter plugin=\"build-name-setter@1.6.5\">/$param<org.jenkinsci.plugins.buildnamesetter.BuildNameSetter plugin=\"build-name-setter@1.6.5\">/g
:x
EOF"
