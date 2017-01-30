#!/bin/bash
#
# Usage: $0 [<backup_dir>]
#
# Create/overwrite snapshots of following vmdevcfm data:
# * Git repositories
# * /local/pub filesystem
#
# If not set, <backup_dir> will use hard-coded default path.
#
# To be executed on 'vmdevcfm' via cron or as required.
#

set -e
set -u
#set -x

# Globals/configuration
DEFAULT_BACKUP_DIR="/local/backup"
RETVAL=0  # used by exit at the end of script
PATH=/bin:/usr/bin

# What to backup
# vmdevcfm specific stuff
GIT_REPOS="/local/git"
JENKINS_JOBS="/local/jenkins/jobs"
GIT_SCM_REPOS="/local/git/repos/"
GIT_SCM="/local/git/scm/"
LOCAL_PUB="/local/pub"

# other stuff
BASHRC=/home/vobadm/.bashrc
PROFILE=/home/vobadm/.profile
REBUILD_SCRIPTS="/home/vobadm/PROD-REBUILD-SCRIPTS"

#
# log_error MESSAGE
#
# Report error MESSAGE to STDERR and set RETVAL to 1 (this allows us to
# report errors and keep going).
#
log_error() # {{{
{
    echo "$(basename $0): Error: $*" >&2
    RETVAL=1
} # }}}

#
# backup_repos SRC_DIR DST_DIR
# backup_repos ~/git ~/backup/git
#
# Recursively find all Git repositories in SRC_DIR and create Git bundle
# inside DST_DIR. Directory structure is preserved (/local/git/cfmrepo/pkg.git
# is created as /backup/git/cfmrepo/pkg.git.bundle).
#
# We create GIT_BACKUP_BASE if one does not exist.
#

backup_repos() # {{{
{
    src_dir="$1"
    dst_dir="$2"

    mkdir -p "$dst_dir"

    repos="$(find $src_dir -type d -name '\.git' | sed 's/\.git$//' | sed 's/\/$//')"

    for repo_path in $repos; do
        # src_dir/subdir/repo.git -> subdir/repo.git.bundle
        bundle_name="${repo_path##$src_dir}.bundle"
        bundle_path="$dst_dir/$bundle_name"
        mkdir -p "$(dirname $bundle_path)"  # create $dst_dir/subdir

        cd "$repo_path"
        # We silence git's STDERR to /dev/null because 'bundle' does not
        # support any -q switch (at least with git-1.7.4.1-1.el5) and it
        # prints out the progress of clone to stderr.
	if git bundle create "$bundle_path" --all 2> /dev/null; then
            echo "Created $bundle_path"
        else
            log_error "Failed to create $bundle_path for $repo_path!"
        fi
    done

} # }}}


#
# backup_git_repos SRC_DIR DST_DIR
# backup_git_repos ~/git ~/backup/git
#
# Recursively find all Git bare repositories in SRC_DIR and create Git bundle
# inside DST_DIR. Directory structure is preserved (/local/git/cfmrepo/pkg.git
# is created as /backup/git/cfmrepo/pkg.git.bundle).
#
# We create GIT_BACKUP_BASE if one does not exist.
#
backup_git_repos() # {{{
{
    src_dir="$1"
    dst_dir="$2"

    mkdir -p "$dst_dir"

    # TODO: Shit will happen if repository path contains space or repository
    # list is too big. Also we support only bare repos in $repo_base.
    repos="$(find "$src_dir" -type d -name '?*.git')"  # ommit '.git'

    for repo_path in $repos; do
        # src_dir/subdir/repo.git -> subdir/repo.git.bundle
        bundle_name="${repo_path##$src_dir}.bundle"
        bundle_path="$dst_dir/$bundle_name"
        mkdir -p "$(dirname $bundle_path)"  # create $dst_dir/subdir

        cd "$repo_path"
        # We silence git's STDERR to /dev/null because 'bundle' does not
        # support any -q switch (at least with git-1.7.4.1-1.el5) and it
        # prints out the progress of clone to stderr.
        if git bundle create "$bundle_path" --all 2> /dev/null; then
            echo "Created $bundle_path"
        else
            log_error "Failed to create $bundle_path for $repo_path!"
        fi
    done
} # }}}

echo "Started $0 at $(date) as $(whoami)"
echo

backup_dir="${1:-$DEFAULT_BACKUP_DIR}"
mkdir -p "$backup_dir"

# Now we get absolute path to backup directory. We need this because we do a
# lot of chdirs and relative path would do things like put backups into .git
# directories and such.
backup_dir="$(cd "$backup_dir" && pwd)"
if [ ! -d "$backup_dir" ]; then
    log_error "Failed to convert backup directory to absolute path!"
    exit 1  # this is critical problem
else
    echo "Backup root is $backup_dir"
fi
echo

dst="$backup_dir/git/scm"
echo "Git repositories backup from $GIT_SCM to $dst"
backup_repos "$GIT_SCM" "$dst"
echo


dst="$backup_dir/git"
echo "Git repositories backup from $GIT_REPOS to $dst"
backup_git_repos "$GIT_REPOS" "$dst"
echo

dst="$backup_dir/git/repos"
echo "Git repositories backup from $GIT_SCM_REPOS to $dst"
backup_git_repos "$GIT_SCM_REPOS" "$dst"

dst="$backup_dir/pub"
mkdir -p $dst
echo "Content of $LOCAL_PUB will be rsync-ed to $dst"
if ! rsync -av $LOCAL_PUB/ $dst; then
    log_error "Failed to backup $LOCAL_PUB"
fi
echo

dst="$backup_dir/jenkins"
mkdir -p $dst
echo "Content of $JENKINS_JOBS will be rsync-ed to $dst"
if ! rsync -av $JENKINS_JOBS/ $dst; then
    log_error "Failed to backup $JENKINS_JOBS"
fi
echo

mkdir -p "$backup_dir/misc"
dst="$backup_dir/misc/.bashrc"
echo ".bashrc will be rsync-ed to $dst"
if ! rsync -av $BASHRC $dst; then
    log_error "Failed to backup $BASHRC"
fi
echo

dst="$backup_dir/misc/.profile"
echo ".profile will be rsync-ed to $dst"
if ! rsync -av $PROFILE $dst; then
    log_error "Failed to backup $PROFILE"
fi
echo

dst="$backup_dir/misc/PROD-REBUILD-SCRIPTS"
echo "$REBUILD_SCRIPTS will be rsync-ed to $dst"
if ! rsync -av $REBUILD_SCRIPTS/ $dst; then
    log_error "Failed to backup $REBUILD_SCRIPTS"
fi
echo


if [ "$RETVAL" -gt 0 ]; then
    log_error "Finished with errors."
    exit $RETVAL
else
    echo "Done."
fi

# vim:foldmethod=marker:ft=sh
