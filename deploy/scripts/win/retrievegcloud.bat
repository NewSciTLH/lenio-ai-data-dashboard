:: Script that retrieves gcloud credentials.
:: Required to have Google Cloud SDK installed and logged into a NewSci account via `gcloud auth login`.
:: ------

@ECHO OFF

ECHO Obtaining Google Cloud Project ID...
:: Obtains currently selected Google Cloud Project ID from logged in user.
FOR /F "delims=" %%i IN ('gcloud config get-value project') DO (
  SET gcloud_project=%%i
) || (
  ECHO An error occurred trying to obtain the current Google Cloud Project. Please ensure that you are logged into a Google account through the CLI, and have chosen a working project.
)

ECHO Obtaining Google Cloud Compute Zone...
:: Obtains currently selected Compute Zone from logged in user.
FOR /F "delims=" %%i IN ('gcloud config get-value compute/zone') DO (
  SET gcloud_zone=%%i
) || (
  ECHO An error occurred trying to obtain the current Google Cloud Compute Zone. Please ensure that you are logged into a Google account through the CLI, and have chosen a working project.
)

ECHO -----
ECHO Google Cloud Project : %gcloud_project%
ECHO Google Cloud Compute Zone: %gcloud_zone%
ECHO -----
