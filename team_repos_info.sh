## Print info of all repos in team

team_id=$1
org=$2

# Find team id:
#for i in {0..1000}; do echo $i; curl -L -s -u $user:$pass -X GET -H "Accept: application/vnd.github.hellcat-preview+json" -H "Content-Type: application/json" $GITHUB/api/v3/teams/$i | egrep 'cs-ifs-digitization';
#done

# e.g $0 441 dev # cs-ifs-devops

/local/git/scm/tools_git/team_repos.sh $team_id | xargs -i -n 1 bash /local/git/scm/tools_git/repo_info.sh {} $org
