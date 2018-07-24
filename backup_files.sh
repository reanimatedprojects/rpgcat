#!/bin/bash

# Where to put the backup file
# Either rename it or alter the following to include the day of week or date
# e.g `date +%a`
TAR=$HOME/rpgcat-files.tar.gz

# Which repository to backup (assumes running as ./backup_files.sh)
GITDIR=$PWD
echo "Found base directory of $GITDIR"

if [ ! -d $GITDIR/.git ]
then
    echo "Failed to locate the .git directory in $GITDIR"
    exit
fi

echo "Backing up untracked/modified files to $TAR";
# Make an archive of all the..
(
    if [[ "$(git --version)" =~ " 2." ]];
    then
        # modified tracked files
        # git2
        git -C $GITDIR ls-files --modified

        # and untracked files
        # git2
        git -C $GITDIR ls-files --others
    else
        # modified tracked files
        # git1.8
        git --work-tree=$GITDIR --git-dir=$GITDIR/.git ls-files --modified

        # and untracked files
        # git1.8
        git --work-tree=$GITDIR --git-dir=$GITDIR/.git ls-files --others
    fi
) | tar -zcvpf $TAR -C $GITDIR --files-from=-

