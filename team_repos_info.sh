## Print info of all repos in team

team_id=$1
org=$2

# e.g $0 441 dev # cs-ifs-devops

/local/git/scm/tools_git/team_repos.sh $team_id | xargs -i -n 1 bash /local/git/scm/tools_git/repo_info.sh {} $org
