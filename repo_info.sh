#!/usr/bin/bash

set -e
set -u

repo=$1
org=$2
GIT_TOOLS=/local/git/scm/GIT/svn2git

d=$(curl -s -i -H "Authorization: token $SCMLUXADM_TOKEN" -X GET $GITHUB/api/v3/repos/$org/$repo | grep description | head -1 | sed 's/\"description\"://g' | sed 's/\"//g' | sed 's/,//g')

echo description:$d

topics=$(curl -L -s -u scmluxadm:$SCMLUXADM_TOKEN -X GET -H "Accept: application/vnd.github.mercy-preview+json" -H "Content-Type: application/json" $GITHUB/api/v3/repos/dev/$repo/topics | egrep -v "{|}|\[|\]" | sed 's/\"//g' | sed 's/,//g' | sed 's/\s//g')

top=''
for t in ${topics[@]}; do
    top+="$t,"
done
    
echo topics:$top

$GIT_TOOLS/repoTeams.py $org $repo

names=$(curl -s -i -H "Authorization: token $SCMLUXADM_TOKEN" -X  \
    GET $GITHUB/api/v3/repos/$org/$repo/collaborators?affiliation=outside\
    | egrep '"login":' | awk '{print $2}' | sed 's/\"//g' | sed 's/\,//g')


admin=$(curl -s -i -H "Authorization: token $SCMLUXADM_TOKEN" -X  \
    GET $GITHUB/api/v3/repos/$org/$repo/collaborators?affiliation=outside\
    | egrep '"admin":' | sed 's/\"admin\": //' | sed 's/\,//' )

push=$(curl -s -i -H "Authorization: token $SCMLUXADM_TOKEN" -X  \
    GET $GITHUB/api/v3/repos/$org/$repo/collaborators?affiliation=outside\
    | egrep '"push":'  | sed 's/\"push\": //' | sed 's/\,//')

pull=$(curl -s -i -H "Authorization: token $SCMLUXADM_TOKEN" -X  \
    GET $GITHUB/api/v3/repos/$org/$repo/collaborators?affiliation=outside\
    | egrep '"pull":'  | sed 's/\"pull\": //' | sed 's/\,//')


export admin_array=($admin)
export push_array=($push)
export pull_array=($pull)

counter=0
perms=''
for name in ${names[@]}; do

    admin=$(eval echo "\${admin_array[\$counter]}")
    if [[ $admin == 'true' ]]; then
        perm='admin'
        perms+=$name,$perm,,
        counter=$((counter+1))
        continue
    fi

    push=$(eval echo "\${push_array[\$counter]}")
    if [[ $push == 'true' ]]; then
        perm='write'
        #echo $name,$perm
        perms+=$name,$perm,,
        counter=$((counter+1))
        continue
    fi

    pull=$(eval echo "\${pull_array[\$counter]}")
    if [[ $pull == 'true' ]]; then
        perm='read'
        counter=$((counter+1))
        #echo $name,$perm
        perms+=$name,$perm,,
        continue
    fi

done

echo collaborators:$perms
