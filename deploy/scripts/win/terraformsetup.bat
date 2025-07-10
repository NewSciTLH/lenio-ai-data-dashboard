:: Script that builds terraform configurations for Cloud Run.
:: - Copies /terraform/cloudrun/ to corresponding new branch directory for setting up autodeployment
:: - Generates variables.tf depending on the envs specified.
:: - Generates .tfvars for automatic embedding of cloud build environment variables.

@ECHO off
SETLOCAL enableDelayedExpansion

SET branch=%1
SET templatedir=.\deploy\terraform\cloudrun
SET newdir=.\deploy\terraform\%branch%
SET basefile=.\deploy\terraform\tfvars.yaml
SET terraformyaml=.\deploy\terraform\templatecloudbuild.yaml
SET buildfile=.\deploy\%branch%cloudbuild.yaml
SET "SPACE=        "

:: Creates new directory if not given.
IF EXIST %newdir% (
    DEL "%newdir%" /s /f /q 1>nul
    rmdir "%newdir%" /s /q 1>nul
)
MKDIR "%newdir%"
:: Copies base terraform files to new directory for given branch.
XCOPY "%templatedir%" "%newdir%" /s /e /y 1>nul

:: Checks and builds cloudbuild.yaml using template and environment variables (substitutions)
IF EXIST %buildfile% (
    DEL "%buildfile%" /s /f /q 1>nul
)
COPY "%basefile%" "%buildfile%" /y 1>nul

:: Creates tfvars from environment variables specified in .envs
IF EXIST .env (
    FOR /F "tokens=1,2 delims==" %%a IN (.env) DO (
        ECHO %%a="" >> %newdir%/terraform.tfvars
        ECHO %SPACE%- '%%a=$_%%a' >> %buildfile%
    )    
)

ECHO. >> %buildfile%

COPY "%buildfile%"+"%terraformyaml%" "%buildfile%" /b /y 1>nul

GOTO :eof
