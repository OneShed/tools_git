#!/bin/bash

set -u
#set -x

# Compare the repo definition in jenkins to the one in Amadeus.xml 

. functions_git

dirname="${PWD}"

cd /local/jenkins/jobs

for file in $(find -maxdepth 2 | grep config.xml | egrep -v _pipe | egrep -v emergency | egrep -v WEEKLY_MF_IMPORT | egrep -v '[[:lower:]]\/*\/'); do
        set +u
        set +e
        grepped=$(grep '\-\-url' $file)

        if [[ -z $grepped ]]; then
            file_pipe=$(echo $file | sed 's/\/config.xml/_pipe\/config.xml/')

            if [[ -f $file_pipe ]]; then
                grepped=$(grep '\-\-url' $file_pipe)
            fi
        fi

        if [[ ! -z "${grepped}" ]]; then
                set -u
                set -e
                f=${file%\/config.xml*}
                appl=${f#\.\/}

                echo "$grepped" | perl -pe 's/.*--url//' | perl -pe 's/.*github.deutsche-boerse.de\///' | awk '{print $1}' | tee /tmp/repo >/dev/null
                repo=$(cat /tmp/repo)

                set +e
                repo_amadeus=`${dirname}/appl_repos_amadeus.pl $appl 2>/dev/null`
                if [[ $? != 0 ]]; then
                    echo Cannot lookup $appl
                    continue
                fi
                set -e

                if ! [[ "${repo_amadeus}" == "${repo}" ]]; then
                    exit_error "$appl repo $repo not matched to $repo_amadeus in Amadeus"
                else
                    echo $appl OK
                fi
        else
            echo "Invalid job $file"
        fi

done
