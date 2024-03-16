#!/bin/bash

declare -A git_commands=(
  [branch]="[--all]:Show the current branch (including submodules). If --all is set, it will show all branches (including submodules)"
  [commit-and-push]="[--force-push] <commit message>:Commit and push changes of all submodules to the remote repositories. This requires all submodules to be on the main branch. If --force-push is set, it will allow to push the submodules even if they are not on the main branch"
)

commands+=([git]=":Manage git operations")
cmd_borg() {
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
    git submodule foreach --recursive "git branch --all"
    git branch --all
  else
    git submodule foreach --recursive "git branch --show-current"
    git branch --show-current
  fi
}

git_commit() {
  local force_push commit_message
  force_push="$1"
  
  if [ "$force_push" != "--force-push" ]; then
    # check if all the submodules are on the main branch
    git submodule --quiet foreach --recursive "git branch --show-current" | grep -v "main" && echo "Some submodules are not on the main branch. Run git branch to see the current branch of each submodule" && return 1
    commit_message="$1"
  else 
    commit_message="$2"
  fi

  if [ -z "$commit_message" ]; then
    echo "Please provide a commit message"
    exit 1
  fi

  git submodule foreach --recursive | tail -r | sed 's/Entering//' | xargs -I% cd % ; git add -A \& git commit -m "$commit_message" 
  
  # push changes with flags 
  git push
  # git submodule foreach --recursive "git add . && git commit -m '$commit_message' && git push"
  git add . && git commit -m "$commit_message" && git push
}