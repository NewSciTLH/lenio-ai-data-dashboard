:: Script for standardizing LOCAL deployment/testing.
:: This script has the following functionality:
    :: 1. Build and run a user's Docker image using the templated flask server.
    :: 2. Run a previously built Docker image.
    :: 3. Run the Flask server locally (not within a Docker container).
:: ------

@ECHO off

:: Setting up local testing for user.
:testlocal
SET /P use_Docker="Do you want to test locally using Docker? (y/n): "
:: Proceeds to the Docker portion.
IF "%use_Docker%"=="y" (
    GOTO :Dockersetup
)
:: Otherwise, starts the flask container locally by running the 'start.py' script.
IF "%use_Docker%"=="n" (
    ECHO +++++
    ECHO Starting Flask server locally...
    ECHO By default, access to the Flask server can be made by making a request to http://localhost:5000
    ECHO Use CTRL+C to end your flask server if needed.
    ECHO +++++
    python start.py
    IF ERRORLEVEL 1 (
        ECHO Please make sure you have a working version of Python 3 installed on your machine.
        GOTO :eof
    )
)
GOTO :eof

:: Prompt user for building new Docker image for application.
:Dockersetup
SET /P build_Docker="Would you like to build a new Docker image for your application? (y/n): "
IF "%build_Docker%"=="y" (
    GOTO :Dockerbuild
)
IF "%build_Docker%"=="n" (
    GOTO :Dockerrun
)
GOTO :eof

:: Build the Docker container given the user's input on name.
:Dockerbuild 
SET /P name_Docker="What would you like to name this Docker container? (PLEASE INSERT IN ALL LOWERCASE): "
ECHO Building Docker Container for Local Testing...
Docker build -t %name_Docker% .
IF ERRORLEVEL 1 (
    ECHO Unsuccessful in building image. Please ensure that the name you chose matches the given criteria.
    GOTO :eof
)

:: Gives user the choice to run the newly built Docker container.
SET /P run_Docker="Would you like to run the Docker container now? (y/n): "
IF "%run_Docker%"=="y" (
    ECHO +++++
    ECHO Running Docker container under image name: %name_Docker%
    ECHO Use CTRL+C to terminate the Docker container at any time.
    ECHO Access the Docker container by accessing localhost:5000
    ECHO +++++
    IF EXIST .env (
      FOR /f %%i in ('docker ps -a -q --filter ancestor^=%name_Docker%') DO docker rm --force %%i
      Docker run -t -i -p 5000:5000 --env-file .env %name_Docker%  
    )
    IF NOT EXIST .env (]
      FOR /f %%i in ('docker ps -a -q --filter ancestor^=%name_Docker%') DO docker rm --force %%i
      Docker run -t -i -p 5000:5000 %name_Docker%  
    )
    IF ERRORLEVEL 1 (
        ECHO Unsuccessful in building image. Please check your requirements.txt or additional files.
        GOTO :eof
    )
    GOTO :eof
)
IF "%run_Docker%"=="n" (
    ECHO +++++
    ECHO If you would like to run your Docker container at any time, the recommended command to run is
    ECHO "Docker run -t -i -p 5000:5000 <name_of_Docker_image>"
    ECHO Use CTRL+C to terminate the Docker container.
    ECHO +++++
    GOTO :eof
)
GOTO :eof


:: Runs the user's previously built Docker container given the proper name.
:Dockerrun
SET /P name_Docker="Input the name of the Docker container you would like to run (PLEASE INSERT IN ALL LOWERCASE): "
ECHO +++++
ECHO Running Docker container....
ECHO Use CTRL+C to terminate the Docker container at any time.
ECHO Access the Docker container by accessing localhost:5000
ECHO +++++
IF EXIST .env (
    FOR /f %%i in ('docker ps -a -q --filter ancestor^=%name_Docker%') DO docker rm --force %%i
    Docker run -t -i -p 5000:5000 --env-file .env %name_Docker%  
)
IF NOT EXIST .env (
    FOR /f %%i in ('docker ps -a -q --filter ancestor^=%name_Docker%') DO docker rm --force %%i
    Docker run -t -i -p 5000:5000 %name_Docker%  
)
IF ERRORLEVEL 1 (
    ECHO Unsuccessful in running image. Make sure that you have Docker enabled on your machine.
    GOTO :eof
)
GOTO :eof
