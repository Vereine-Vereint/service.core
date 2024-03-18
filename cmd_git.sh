#!/bin/bash

declare -A git_commands=(
  [branch]="[--all]:Show the current branch (including submodules). If --all is set, it will show all branches (including submodules)"
  [commit]="[--push] [--force-branch] <commit message>:Commit changes of all submodules and if --push is set, push to the remote repositories. This requires all submodules to be on the main branch. If --force-branch is set, it will allow to commit (and push) the submodules even if they are not on the main branch"
  [pull]=":Pull changes of all submodules from their remote repositories on their main branch"
)

commands+=([git]=":Manage git operations")
cmd_git() {
  local command="$1"

  if [[ ! " ${!git_commands[@]} " =~ " $command " ]]; then
    print_help "git " "git_commands"
    if ! [[ -z "$command" ]]; then
      echo
      echo "Unknown command: git $command"
    fi
    exit 1
  fi

  cd $SERVICE_DIR
  shift # remove first argument ("git" command)
  git_$command "$@"
}

git_branch() {
  local all
  all="$1"
  if [ "$all" == "--all" ]; then
    git submodule foreach --recursive "git --no-pager branch --all | sed 's/^/  /'"
    echo "Parent repository"
    git --no-pager branch --all | sed 's/^/  /'
  else
    git submodule foreach --recursive "git --no-pager branch --show-current | sed 's/^/  /'"
    echo "Parent repository"
    git --no-pager branch --show-current | sed 's/^/  /'
  fi
}

git_commit() {
  local push force_branch commit_message

  while [ "$1" != "" ]; do
    case $1 in
      --push) push=1
        ;;
      --force-branch) force_branch=1
        ;;
      *) commit_message="$1"
        ;;
    esac
    shift
  done

  if [ -z "$commit_message" ]; then
    echo "Please provide a commit message"
    exit 1
  fi

  # if force branch is not set, check if all the submodules are on the main branch
  if [ -z "$force_branch" ]; then
    git submodule --quiet foreach --recursive "git branch --show-current" | grep -v "main" && echo "Some submodules are not on the main branch. Run git branch to see the current branch of each submodule or add the --force-branch option." && return 1
  fi

  current_working_dir=$(pwd)
  git submodule foreach --recursive | tail -r | sed -e "s/Entering //" -e "s/'//g" | while read -r line; do
    cd $line
    echo "Commiting changes in submodule $line (dir: $(pwd))"

    git add -A
    git commit -m "$commit_message" | sed 's/^/  /'

    # new line
    echo

    cd $current_working_dir
  done

  echo "Commiting changes in the parent repository"
  git add -A
  git commit -m "$commit_message" | sed 's/^/  /'
  echo

  # if push is set, push the changes to the remote repositories
  if [ -n "$push" ]; then
    echo "Pushing changes to the remote repositories"
    git submodule foreach --recursive "git push | sed 's/^/  /'"
    echo "Pushing changes to the parent repository"
    git push | sed 's/^/  /'
  fi
}

git_pull() {
  git submodule foreach --recursive "git checkout main && git pull"
}