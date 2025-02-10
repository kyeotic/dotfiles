#!/usr/bin/env bash
#
# This script deletes all local branches that were squashed and merged (such
# as from the GitHub / GitLab web UI).
#
# Modified from https://stackoverflow.com/a/56026209/1354930
#
# It's really only used in a git alias 'prune-squash-merged' (see
# https://stackoverflow.com/a/46435987/1354930).
#
# It supports a "dry run" mode with either the '-n' or '--dry-run' arg.
# Parse args
# See https://stackoverflow.com/a/33826763/1354930
BASE_BRANCH="${1:-main}"  # Use the first argument, default to 'main' if not provided
DRY_RUN=0
shift  # Move past the first argument (the base branch)

# Parse remaining args for dry-run flag
while [[ "$#" -gt 0 ]];
do
	case $1 in
		-n|--dry-run) DRY_RUN=1; shift ;;
		*) echo "Unknown parameter passed: $1"; exit 1 ;;
	esac
	shift
done

echo "Pruning local branches that were squashed and merged onto $BASE_BRANCH..."
if [[ $DRY_RUN -eq 1 ]]
then
	echo "DRY RUN - no branches will be deleted.";
fi;

# Prune local branches that we squashed and merged.
# See https://stackoverflow.com/a/56026209/1354930
git checkout -q "$BASE_BRANCH" &&
git for-each-ref refs/heads/ "--format=%(refname:short)" |
while read branch;
do mergeBase=$(git merge-base "$BASE_BRANCH" $branch) &&
	[[ $(git cherry "$BASE_BRANCH" $(git commit-tree $(git rev-parse "$branch^{tree}") -p $mergeBase -m _)) == "-"* ]] &&
	if [[ $DRY_RUN -eq 1 ]]
	then
		echo "$branch is merged into $BASE_BRANCH and can be deleted";
	else
		git branch -D $branch;
	fi;
done
