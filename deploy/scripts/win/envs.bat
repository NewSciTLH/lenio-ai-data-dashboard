:: Script that adds environment variables to .env file for ingestion into Cloud Build/Terraform

@ECHO off
SETLOCAL EnableDelayedExpansion

ECHO ++++
ECHO Environment Variable control
ECHO ++++

:: Checks environment variables file if it exists.
IF EXIST .env (
  ECHO File `env` already exists. Proceeding to environment variable configuation...
) ELSE (
  ECHO Building `env` file for storing environment variables...
  FSUTIL file createnew .env 0
  ECHO You can manually add environment variables to this file, or use this tool to add them yourselves.
  ECHO Environment variables are represented as a key-value pair.
  ECHO Ex. "Key=value"
  ECHO This file will and should only be stored on your local machine. It will not be stored in GitHub/Google Cloud.
  ECHO -----
)

ECHO THESE ENVIRONMENT VARIABLES WILL BE EMBEDDED INTO THE DOCKER CONTAINER.
:menu
:: Environment Variables menu
ECHO Input the corresponding number to select an option:
ECHO 1: Add Environment Variable
ECHO 2: Edit Environment Variable
ECHO 3: Delete Environment Variable
ECHO 0: Exit Application 
SET /P option="Option: "
ECHO -----
:: Conditional if the user wants to test locally.
IF "%option%"=="1" (
  GOTO :add
)
:: Conditional if the user wants to setup autodeployment using Cloud Build
IF "%option%"=="2" (
  GOTO :edit
)
IF "%option%"=="3" (
  GOTO :delete
)
:: Conditional if user exits application.
IF "%option%"=="0" (
  GOTO :eof
)
GOTO :eof

:: Begins addition process of environment variables.
:add
ECHO Environment variables are represented as a key-value pair. THE KEY MUST BE IN UPPERCASE FORM.
ECHO Ex. "Key=value"
:addstart
SET /P key="Please input the key of the variable: "
CALL :toupper key
SET /P value="Please input the value of the variable: "
SET pair=%key%=%value%
SET pair=%pair: =%
FOR /F "delims=" %%a in (.env) DO (
  ECHO %%a >> .newenv
)
ECHO %pair% >> .newenv
XCOPY ".newenv" ".env" /y 1>nul
DEL ".newenv" /s /f /q 1>nul
ECHO Environment variable added.
ECHO To apply this new variable to your remote deployment, you must update the cloud build trigger.
SET /P choice="Would you like to add another environment variable? (y/n): "
IF "%choice%"=="y" (
  GOTO :addstart
)
ECHO Returning to menu...
GOTO :menu

:: Begins editing process of already-existing environment variables.
:edit
ECHO Here are the keys for the currently implemented environment variables:
ECHO -----
CALL deploy/scripts/win/listenvs all
ECHO 0: Return to environment variables menu. [COMMAND NOT ENV VAR]

ECHO Which environment variable would you like to edit?
SET /P keynum="Please type in the number corresponding to the key: "
SET /A check=%keynum% + 0
IF %check%==0 (
  ECHO Returning to menu...
  GOTO :menu
)
SET /P editvalue="Please enter the new value of this variable: "
SET /A COUNT=1
FSUTIL file createnew .newenv 0
FOR /F "delims=" %%x in (.env) DO (
  IF NOT "!COUNT!"=="%keynum%" (
    ECHO %%x >> .newenv  
  )
  IF "!COUNT!"=="%keynum%" (
    FOR /F "tokens=1,2 delims==" %%a in ("%%x") DO (
      SET newkey=%%a
      SET newpair=!newkey!=%editvalue%
      SET newpair=!newpair: =!
      ECHO !newpair! >> .newenv
    )    
  )
  SET /A COUNT+=1 
)
XCOPY ".newenv" ".env" /y 1>nul
DEL ".newenv" /s /f /q 1>nul
ECHO To apply this variable update to your remote deployment, you must update the cloud build trigger.
GOTO :edit

:: Begins deletion process of environment variables.
:delete
ECHO Here are the keys for the currently implemented environment variables:
ECHO -----
CALL deploy/scripts/win/listenvs keys
ECHO 0: Return to environment variables menu. [COMMAND NOT ENV VAR]

ECHO Which environment variable would you like to remove?
SET /P keynum="Please type in the number corresponding to the key: "
SET /A check=%keynum% + 0
IF %check%==0 (
  ECHO Returning to menu...
  GOTO :menu
)

SET /A COUNT=1
FSUTIL file createnew .newenv 0
FOR /F "delims=" %%a in (.env) DO (
  IF NOT "!COUNT!"=="%keynum%" (
    ECHO %%a >> .newenv 
  )
  SET /A COUNT+=1 
)
XCOPY ".newenv" ".env" /y 1>nul
DEL ".newenv" /s /f /q 1>nul
ECHO Environment variable removed.
GOTO :delete

:: Converts given input to uppercase.
:toupper
FOR %%a IN ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") DO (
  CALL SET %~1=%%%~1:%%~a%%
)
GOTO :eof