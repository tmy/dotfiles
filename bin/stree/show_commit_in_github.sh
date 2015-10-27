#!/bin/bash

REPO="$1"
SHA="$2"

cd "$REPO"

remote=$(git config --get "branch.master.remote")
remote_url=$(git config --get "remote.$remote.url")
github_url=$(echo "$remote_url $SHA" | perl -ne 'print "https://github.com/$1/$2/commit/$3" if m|github\.com:(.*)/(.*)\.git (.*)|')

if [ -n "$github_url" ] ; then
    open "$github_url"
else
    echo "Remote repository $remote_url is not github."
    exit 1
fi
