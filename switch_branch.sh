#!/usr/bin/env bash

usage() {
    #if [ "$*" ]; then
    #    echo "$*"
    #    echo
    #fi
    echo "Usage: "$(basename $0)" branch-name|push"
    echo "                                                "
    exit 2
}

switchBranch() {
    BRANCH_NAME="$1"
    echo "switchBranch ${BRANCH_NAME}"
    cd repository
    git branch ${BRANCH_NAME}
    git switch --discard-changes "${BRANCH_NAME}"
    echo ${BRANCH_NAME} > switched
}

pushBranch() {
    BRANCH_NAME="$1"
    echo "pushBranch ${BRANCH_NAME}"
    cd repository
    rm -f switched
    find . -type d -name node_modules -exec rm -rf {} \;
    mkdir -p "../${BRANCH_NAME}/"
    rsync -hvar --delete --force --exclude=.git ./ "../${BRANCH_NAME}/"
    git add --all
    git commit -m "${BRANCH_NAME} changes"
    git push --set-upstream origin ${BRANCH_NAME}
    cd ..
}

if [ ! -f ./git_project.txt ];
then
    echo "Can't found the git_project.txt file"
    exit -2
fi

GIT_PROJECT="$(<./git_project.txt)" 2> /dev/null

if [ ! -d "repository" ];
then
    git clone ${GIT_PROJECT} repository
fi

BRANCH_NAME=""
ACTION=""

if [ -z "$1" ];
then
    usage
fi

if [ -f ./repository/switched ];
then
    BRANCH_NAME=$(<./repository/switched ) 2> /dev/null
fi

if [ "$1" == "push" ];
then
    ACTION=$1
else
    if [ "$1" != "${BRANCH_NAME}"] ];
    then
        BRANCH_NAME=$1
        ACTION="switch"
    fi
fi

if [ -z $BRANCH_NAME ];
then
    usage
fi

if [ "${ACTION}" == "switch" ];
then
    switchBranch "${BRANCH_NAME}"
else 
    if [ "${ACTION}" == "push" ];
    then
        pushBranch "${BRANCH_NAME}"
    else
        usage
    fi
fi

