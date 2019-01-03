#!/bin/bash
#
#  Adds one or more topics to a set of GIT repositories.
#
#  25.04.2018   Rainer Hochschild   initial version
#  03.08.2018   Rainer Hochschild   add organisation parameter, add quoting of credentials
#  11.01.2019   Jan Spatina         add api token option 
#
#

toolName=$(basename "$0")

# Suppress any GUI dialogs for credentials (this is a command line tool!).
sshAskPassValue=$SSH_ASKPASS
unset SSH_ASKPASS

screen2=/dev/null
gitServerURL="https://github.deutsche-boerse.de"
gitOrg="dev"
gitUser=$(whoami)
gitPassword=""

# Uncomment and edit this list if you want to skip the definition of target repos on the command line.
# repositories=()
# Uncomment and edit this list if you want to skip the definition of target repos on the command line.
# githubTopics=()

function usage
{
    echo ""
    echo "Usage:  $toolName [options]"
    echo ""
    echo "  e.g.  $toolName -r EurexBESS -t clearingit -v"
    echo ""
    echo "  Options available:"
    echo "  -r repo    git repository name (mandatory, may be repeated for multiple repos)"
    echo "  -t topic   the topic to be added (mandatory, all lowercase, may be repeated for multiple topics)"
    echo "  -o name    name of git organisation (default is 'dev')"
    echo "  -u user    git user name (optional, default is current user)"
    echo "  -p pass    git password (optional, special characters may have to be masked properly!)"
    echo "  -k token   github api token (optional, special characters may have to be masked properly!)"
    echo "  -h         print help"
    echo "  -v         print more messages (verbose mode)"
    echo ""
    echo "  Append ' ; history -d \$((HISTCMD-1)) ' to suppress the call in the bash command history when specifying the -p parameter!"
    echo ""
    exit 0;
}

set -x

function parseCommandLine
{
    while getopts "o:p:k:r:t:u:hv" o; do
        # echo "Option: $o     Parameter: $OPTARG"
        case "${o}" in
            h)  usage ;;
            o)  gitOrg=${OPTARG} ;;
            p)  gitPassword=${OPTARG} ;;
            k)  gitToken=${OPTARG} ;;
            r)  repositories+=(${OPTARG}) ;;
            t)  githubTopics+=(${OPTARG}) ;;
            u)  gitUser=${OPTARG} ;;
            v)  screen2=/dev/stdout ;;
            *)  usage ;;
        esac
    done

    # Apply basic checks to input parameters.
    # Check if the mandatory repository parameter is specified.
    if [ ${#repositories[@]} -eq 0 ]
    then
        echo "ERROR: The -r <repository> parameter is missing."
        usage
    elif [ ${#githubTopics[@]} -eq 0 ]
    then
        echo "ERROR: The -t <topic> parameter is missing."
        usage
    fi
}


# Parse command line parameters.
# Printing the help if no parameter is given is just a design decision.
if [ $# == 0 ]
then
    usage
else
    parseCommandLine "$@"
fi

if [ -z "$gitPassword" ]
then
    curlCreds=${gitUser}    # Without password curl will prompt for input!
else
    curlCreds="${gitUser}:${gitPassword}"
fi

if [ -z "$gitToken" ]
then
    curlCreds=${gitUser}    # Without token curl will prompt for input!
else
    curlCreds="${gitUser}:${gitToken}"
fi

# Process the repositories one after another:
for repoName in "${repositories[@]}"
do
    echo "Processing repository $repoName"
    # Read the existing topics
    echo "  Getting existing topics" >> $screen2
    curlGetOpts='-L -s -u '"'${curlCreds}'"' -X GET -H "Accept: application/vnd.github.mercy-preview+json" -H "Content-Type: application/json"'
    url="$gitServerURL/api/v3/repos/$gitOrg/$repoName/topics"
    getCommand="curl $curlGetOpts $url"
    oldData=$(eval $getCommand |  tr -d '\n')

    echo "old Data:  $oldData" >> $screen2
    # Add quoting and comma separator to raw topics.
    newTopics=$(printf '"%s", ' "${githubTopics[@]}")
    # Remove the last trailing comma+blank separator if there were no topics previously (old data is empty).
    # Otherwise GitHub will complain about invalid JSON.
    if echo "$oldData" | egrep -q '\[\W+\]'
    then
        newTopics=${newTopics%, }
    fi
    # Insert new topics into existing topics response data (JSON format).
    newData=${oldData/[/[ $newTopics}
    echo "new Data:  $newData" >> $screen2
    # Add appropriate quotation to insert the JSON data in the bash command line
    finalData=$(printf '%q' $newData)

    echo "  Adding new topics" >> $screen2
    updateOpts='-L -s -u ${curlCreds} -X PUT -H "Accept: application/vnd.github.mercy-preview+json" -H "Content-Type: application/json" '
    url="$gitServerURL/api/v3/repos/$gitOrg/$repoName/topics"
    updateCommand="curl $updateOpts -d $finalData $url"
    eval $updateCommand
done
