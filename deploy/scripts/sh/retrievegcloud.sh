#!/bin/bash
# Script that retrieves gcloud credentials.
# Required to have Google Cloud SDK installed and logged into a NewSci account via `gcloud auth login`.
# ------

echo 'Obtaining Google Cloud Project ID...'
# Obtains currently selected Google Cloud Project ID from logged in user.
gcloud_project=$(gcloud config get-value project)
if [ "$?" != "0" ]
then
    echo 'An error occurred trying to obtain the current Google Cloud Project. Please ensure that you are logged into a Google account through the CLI, and have chosen a working project.'
    exit
fi

echo 'Obtaining Google Cloud Compute Zone...'
# Obtains currently selected Compute Zone from logged in user.
gcloud_zone=$(gcloud config get-value compute/zone)
if [ "$?" != "0" ]
then
    echo 'An error occurred trying to obtain the current Google Cloud Compute Zone. Please ensure that you are logged into a Google account through the CLI, and have chosen a working project.'
    exit
fi

echo '-----'
echo 'Google Cloud Project :' $gcloud_project
echo 'Google Cloud Compute Zone:' $gcloud_zone
echo '-----'
