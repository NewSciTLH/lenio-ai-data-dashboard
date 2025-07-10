:: Script for standardizing deploying a Docker Image stored to the cloud.
:: The cloud trigger build files are located in terraform/cloudrun. Relates to deployment to Cloud Run.
:: ------

@ECHO off

ECHO +++++
ECHO Cloud Build Trigger Automation Setup
ECHO +++++

CALL deploy/scripts/win/retrievegcloud

ECHO These specify where the application will be deployed.
SET region=%gcloud_zone:~0,-2%
SET /P choice="Are these configurations correct? (y/n) : "
IF "%choice%"=="y" (
  GOTO :configurecloudbuild
)
:: Conditional if the user wants to setup autodeployment using Cloud Build
IF "%choice%"=="n" (
  ECHO Run `gcloud init` to change your Google Project ID and Compute Zone.
  ECHO Cancelling cloud build automation process...
)
GOTO :eof


:configurecloudbuild
:: Automatically sets the following:
::  Repository owner to organization: NewSciTLH
::  Path to build configuration file: ./deploy/<branch>cloudbuild.yaml
::  Remote branch name: origin (by default is set to this on git clone/template)
SET repo_owner=NewSciTLH
SET origin=origin
:: Finds Repository name given the remote URL string.
FOR /F "delims=" %%i IN ('git config --get remote.%origin%.url') DO (
  SET remote_repo=%%i
)
FOR /F %%a IN ("%remote_repo%") DO (
  SET repo_name=%%~na
)
:: Input for remote branch to set autodeployment for.
ECHO Which remote branch would you like to track this automation process for?
SET /P branch="(default is master) Branch: " || SET branch=master
SET build_config=deploy/%branch%cloudbuild.yaml

:: Asks user for input to Google Cloud Sotrage bucket to hold terraform state.
:inputbucket
ECHO Which Cloud Storage Bucket will keep track of the deployment's build state?
ECHO +++++
ECHO + 1. This is used to keep track of terraform build state.
ECHO + 2. Ensures that multiple simultaneous updates do not crash a build.
ECHO + 3. If you are unsure about the Cloud Storage Bucket, please contact a peer at NewSci.
ECHO +++++
SET /P cloud_bucket="Bucket: "

SET /P description="Give a description for this trigger (can be left blank): "

:: Builds trigger activation type based on input (push or pull request).
:choosetriggertype
SET /P trigger="Do you want to set this build to trigger by a PUSH or PULL REQUEST? (push/pull): "
IF "%trigger%"=="push" (
  SET trigger_string=--branch-pattern="%branch%"
  GOTO :cloudbuildconfigs
)
IF "%trigger%"=="pull" (
  SET trigger_string=--pull-request-pattern="%branch%"
  GOTO :cloudbuildconfigs
)
ECHO Wrong input given, must be either `push` or `pull`.
GOTO :choosetriggertype

:: Generates cloud build configurations based on inputs
:cloudbuildconfigs
CALL :envsubstitutions %cloud_bucket% %build_substitutions%
ECHO Cloud Build Trigger Configurations:
ECHO -----
ECHO Repository Name: %repo_name%
ECHO Repository Owner: %repo_owner%
ECHO Branch: %branch%
ECHO Cloud Storage Bucket: %cloud_bucket%
ECHO Description: %description%
ECHO Trigger: %trigger%
ECHO Environment Variables: %build_substitutions%
ECHO -----
SET /P build_choice="Are you sure you want to begin building the trigger? (y/n): "
IF "%build_choice%"=="y" (
  GOTO :buildcloudtrigger
)
:: Conditional if the user wants to setup autodeployment using Cloud Build
IF "%build_choice%"=="n" (
  ECHO Cancelling cloud build automation process...
)
GOTO :eof

:: Builds the cloud trigger.
:buildcloudtrigger
CALL :buildterraform
ECHO Attempting to create Cloud Build Trigger...
ECHO -----
SET name=%repo_name%-%branch%
:: Converts trigger name to all lowercase.
SET locase=FOR /L %%n IN (1 1 2) DO IF %%n==2 ( FOR %%# IN (a b c d e f g h i j k l m n o p q r s t u v w x y z) DO SET lowername=!lowername:%%#=%%#!) ELSE SETLOCAL enableDelayedExpansion ^& SET lowername=
%locase%%name%

gcloud beta builds triggers create github ^
--name="%lowername%" ^
--repo-name="%repo_name%" ^
--repo-owner="%repo_owner%" ^
--build-config="%build_config%" ^
--description="%description%" ^
%trigger_string% ^
--substitutions %build_substitutions% ^
&& (
  ECHO +++++
  ECHO Autodeployment setup successful!
  ECHO Everytime a push is made to this repository's %branch% branch, a Cloud Build automated build will occur.
  ECHO +++++
) || (
  ECHO An error occurred during generating the Cloud Build Trigger. Please ensure that the repository exists.
)
GOTO :eof

:: Builds the environment variables (substitutions) to be inputted into the Cloud Build Trigger.
:envsubstitutions
SETLOCAL EnableDelayedExpansion

SET cloud_bucket=STATE_BUCKET=%1
SET region=REGION=%region%
SET build_substitutions=_%cloud_bucket%,_%region%
IF EXIST .env (
  FOR /F "delims=" %%x in (.env) DO (
    SET build_substitutions=!build_substitutions!,_%%x
    :: Removes unnecessary spaces between environment variables
    SET build_substitutions=!build_substitutions: =!
  )
)
(
  ENDLOCAL
  SET build_substitutions=%build_substitutions%
)
EXIT /b

:buildterraform
CALL deploy/scripts/win/terraformsetup %branch%
EXIT /b
