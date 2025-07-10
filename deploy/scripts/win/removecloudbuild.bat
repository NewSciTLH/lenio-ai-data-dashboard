:: Script for removing a pre-existing 
:: The cloud trigger build files are located in terraform/cloudrun. Relates to deployment to Cloud Run.
:: ------

@ECHO off

ECHO +++++
ECHO Cloud Build Trigger Removal
ECHO +++++

CALL deploy/scripts/win/retrievegcloud

ECHO The following is the Google Cloud credentials where the Cloud Build Trigger is deployed.
SET /P choice="Are these configurations correct? (y/n) : "
IF "%choice%"=="y" (
  GOTO :inputbranch
)
:: Conditional if the user wants to setup autodeployment using Cloud Build
IF "%choice%"=="n" (
  ECHO Run `gcloud init` to change your Google Project ID and Compute Zone.
  ECHO Cancelling cloud build deletion process...
)
GOTO :eof

:inputbranch
ECHO Which remote branch would you like to remove this trigger for?
SET /P branch="(default is master) Branch: " || SET branch=master
SET origin=origin
:: Finds Repository name given the remote URL string.
FOR /F "delims=" %%i IN ('git config --get remote.%origin%.url') DO (
  SET remote_repo=%%i
)
FOR /F %%a IN ("%remote_repo%") DO (
  SET repo_name=%%~na
)

SET name=%repo_name%-%branch%
:: Converts trigger name to all lowercase.
SET locase=FOR /L %%n IN (1 1 2) DO IF %%n==2 ( FOR %%# IN (a b c d e f g h i j k l m n o p q r s t u v w x y z) DO SET lowername=!lowername:%%#=%%#!) ELSE SETLOCAL enableDelayedExpansion ^& SET lowername=
%locase%%name%

echo y | gcloud beta builds triggers delete %lowername% --quiet
