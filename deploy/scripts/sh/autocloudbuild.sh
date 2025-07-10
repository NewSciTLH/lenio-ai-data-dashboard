#!/bin/bash
# Script for standardizing deploying a Docker Image stored to the cloud.
# The cloud trigger build files are located in terraform/cloudrun. Relates to deployment to Cloud Run.
# ------

# Builds the cloud trigger.
build_cloud_trigger () {
    . deploy/scripts/sh/terraformsetup.sh $branch
    echo 'Attempting to create Cloud Build Trigger...'
    echo '-----'
    name="$repo_name-$branch"
    lowername="$(tr [A-Z] [a-z] <<< "$name")"

    gcloud beta builds triggers create github \
    --name="$lowername" \
    --repo-name="$repo_name" \
    --repo-owner="$repo_owner" \
    --build-config="$build_config" \
    --description="$description" \
    $trigger_string \
    --substitutions $build_substitutions
    if [ "$?" != "0" ]
    then
        echo 'An error occurred during generating the Cloud Build Trigger. Please ensure that the repository exists.'
        exit
    else
        echo '+++++'
        echo 'Autodeployment setup successful!'
        echo 'Everytime a push is made to this repository '$branch' branch, a Cloud Build automated build will occur.'
        echo '+++++'
    fi
    exit  
}

# Builds the environment variables (substitutions) to be inputted into the Cloud Build Trigger.
env_substitutions () {
    env_cloud_bucket="_STATE_BUCKET=$1"
    env_region="_REGION=$2"
    build_necessities="$env_cloud_bucket,$env_region"
    if [ -f ".env" ]
    then
        while IFS= read -r line
        do
            env_vars+=",_${line}"
        done < ".env"
    fi
    build_substitutions="$build_necessities$env_vars"
}

# Generates cloud build configurations based on inputs
cloudbuild_configs () {
    env_substitutions $cloud_bucket $region
    echo 'Cloud Build Trigger Configurations:'
    echo '-----'
    echo 'Repository Name:' $repo_name
    echo 'Repository Owner:' $repo_owner
    echo 'Branch:' $branch
    echo 'Cloud Storage Bucket:' $cloud_bucket
    echo 'Description:' $description
    echo 'Trigger:' $trigger
    echo 'Environment Variables:' $build_substitutions
    echo '-----'
    read -p 'Are you sure you want to begin building the trigger? (y/n): ' build_choice
    if [ "$build_choice" == "y" ]
    then
        build_cloud_trigger
    # Conditional if the user wants to setup autodeployment using Cloud Build
    elif [ "$build_choice" == "n" ]
    then
        echo 'Cancelling cloud build automation process...'
        exit
    fi
    exit
}

# Builds trigger activation type based on input (push or pull request).
choose_trigger () {
    read -p 'Do you want to set this build to trigger by a PUSH or PULL REQUEST? (push/pull): ' trigger
    if [ "$trigger" == "push" ] 
    then
        trigger_string=--branch-pattern="$branch"
        cloudbuild_configs
    elif [ "$trigger" == "pull" ]
    then
        trigger_string=--pull-request-pattern="$branch"
        cloudbuild_configs
    fi
    echo 'Wrong input given, must be either `push` or `pull`.'
    choose_trigger    
}

# Asks user for input to Google Cloud Sotrage bucket to hold terraform state.
input_bucket () {
    echo 'Which Cloud Storage Bucket will keep track of the deployment build state?'
    echo '+++++'
    echo '+ 1. This is used to keep track of terraform build state.'
    echo '+ 2. Ensures that multiple simultaneous updates do not crash a build.'
    echo '+ 3. if you are unsure about the Cloud Storage Bucket, please contact a peer at NewSci.'
    echo '+++++'
    read -p 'Bucket: ' cloud_bucket
    read -p 'Give a description for this trigger (can be left blank): ' description

    choose_trigger
}

# Automatically sets the following:
#  Repository owner to organization: NewSciTLH
#  Path to build configuration file: ./deploy/<branch>cloudbuild.yaml
#  Remote branch name: origin (by default is set to this on git clone/template)
configure_cloudbuild () {
    repo_owner=NewSciTLH
    origin=origin
    # Finds Repository name given the remote URL string.
    remote_repo=$(git config --get remote.$origin.url)
    repo_name=$(basename ${remote_repo%????})
    # Input for remote branch to set autodeployment for.
    echo 'Which remote branch would you like to track this automation process for?'
    read -p "(default is master) Branch: " branch
    branch=${branch:-master}
    build_config='deploy/'$branch'cloudbuild.yaml'
    input_bucket
}

echo '+++++'
echo 'Cloud Build Trigger Automation Setup'
echo '+++++'

. deploy/scripts/sh/retrievegcloud.sh
region=${gcloud_zone%??}
echo 'These specify where the application will be deployed.'
read -p 'Are these configurations correct? (y/n) : ' choice
if [ "$choice" == "y" ]
then
  configure_cloudbuild
# Conditional if the user wants to setup autodeployment using Cloud Build
elif [ "$choice" == "n" ]
then
  echo 'Run `gcloud init` to change your Google Project ID and Compute Zone.'
  echo 'Cancelling cloud build automation process...'
fi
exit