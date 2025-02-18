

function gpup
    if test -z "$argv[1]"
        set BRANCH 'main'
    else
        set BRANCH $argv[1]
    end
    
    git fetch --all --prune
    git fetch origin $BRANCH:$BRANCH
    git checkout $BRANCH
    gprunesquashmerged $BRANCH
end

function gprunesquashmerged
    # Set MAIN_BRANCH to the first argument or default to 'main'
    if test -z "$argv[1]"
        set BRANCH 'main'
    else
        set BRANCH $argv[1]
    end

    # Check out the MAIN_BRANCH to ensure we're on the correct branch
    git checkout -q $MAIN_BRANCH

    for branch in (git for-each-ref --format '%(refname:short)' refs/heads/)
        # Skip the MAIN_BRANCH itself to prevent trying to delete it
        if string match -q $MAIN_BRANCH $branch
            continue
        end

        # Ensure branch is not empty before calling git merge-base
        if not set -q branch
            echo "Skipping empty branch name"
            continue
        end

        # Get the merge base of the MAIN_BRANCH and the current branch
        set mergeBase (git merge-base $MAIN_BRANCH $branch)
        
        # Use git cherry to see if the branch is already merged into MAIN_BRANCH
        set cherry_result (git cherry $MAIN_BRANCH $branch)

        # If the branch is completely cherry-picked into MAIN_BRANCH (starts with '-')
        if string match -r "^-*" $cherry_result
            echo "Branch $branch is already merged, deleting it."
            git branch -D $branch
        end
    end
end
