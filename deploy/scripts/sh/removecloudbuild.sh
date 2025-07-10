#!/bin/bash
# Script for removing a pre-existing 
# The cloud trigger build files are located in terraform/cloudrun. Relates to deployment to Cloud Run.
# ------

input_branch () {
  echo 'Which remote branch would you like to remove this trigger for?'
  read -p "(default is master) Branch: " branch
  branch=${branch:-master}
  origin=origin
  # Finds Repository name given the remote URL string.
  remote_repo=$(git config --get remote.$origin.url)
  repo_name=$(basename ${remote_repo%????})
  name="$repo_name-$branch"
  # Converts trigger name to all lowercase.
  lowername="$(tr [A-Z] [a-z] <<< "$name")"
}

echo '+++++'
echo 'Cloud Build Trigger Removal'
echo '+++++'

. deploy/scripts/sh/retrievegcloud.sh

echo 'The following is the Google Cloud credentials where the Cloud Build Trigger is deployed.'
read -p 'Are these configurations correct? (y/n) : ' choice
if [ "$choice" == "y" ] 
then
  input_branch
  echo y | gcloud beta builds triggers delete $lowername --quiet
# Conditional if the user wants to setup autodeployment using Cloud Build
elif [ "$choice" == "n" ]
then
  echo 'Run `gcloud init` to change your Google Project ID and Compute Zone.'
  echo 'Cancelling cloud build deletion process...'
fi
exit
