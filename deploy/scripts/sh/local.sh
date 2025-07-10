#!/bin/bash
# Script for standardizing LOCAL deployment/testing.
# This script has the following functionality:
    # 1. Build and run a user's Docker image using the templated flask server.
    # 2. Run a previously built Docker image.
    # 3. Run the Flask server locally (not within a Docker container).
# ------
# Prompt user for building new Docker image for application.
docker_setup () {
    read -p 'Would you like to build a new Docker image for your application? (y/n): ' build_Docker
    if [ "$build_Docker" == "y" ]
    then
        docker_container
    elif [ "$build_Docker" == "n" ]
    then
        docker_run_prev
    fi
    exit
}

# Build the Docker container given the user's input on name.
docker_container () {
    read -p "What would you like to name this Docker container? (PLEASE INSERT IN ALL LOWERCASE): " name_Docker
    echo 'Building Docker Container for Local Testing...'
    docker build -t $name_Docker .
    if [ "$?" != "0" ]
    then
        echo 'Unsuccessful in building image. Please ensure that the name you chose matches the given criteria.'
        exit
    fi
    docker_run $name_Docker
}

# Gives user the choice to run the newly built Docker container.
docker_run () {
    read -p 'Would you like to run the Docker container now? (y/n): ' run_Docker
    if [ "$run_Docker" == "y" ]
    then
        echo '+++++'
        echo 'Running Docker container under image name:' $1
        echo 'Use CTRL+C to terminate the Docker container at any time.'
        echo 'Access the Docker container by accessing localhost:5000'
        echo '+++++'
        if [ -f ".env" ]
        then
            # for %%i in ['docker ps -a -q --filter ancestor^='$1] DO docker rm --force %%i
            docker run -t -i -p 5000:5000 --env-file .env $1
            if [ "$?" != "0" ]
            then
                echo 'Unsuccessful in building image. Please check your requirements.txt or additional files.'
                exit
            fi
        else
            # FOR /f %%i in ('docker ps -a -q --filter ancestor^=%name_Docker%') DO docker rm --force %%i
            docker run -t -i -p 5000:5000 $1
            if [ "$?" != "0" ]
            then
                echo 'Unsuccessful in building image. Please check your requirements.txt or additional files.'
                exit
            fi
        fi
    elif [ "$run_Docker" == "n" ]
    then
        echo '+++++'
        echo 'if you would like to run your Docker container at any time, the recommended command to run is'
        echo '"Docker run -t -i -p 5000:5000 <name_of_Docker_image>"'
        echo 'Use CTRL+C to terminate the Docker container.'
        echo '+++++'
    fi
    exit
}

# Runs the user's previously built Docker container given the proper name.
docker_run_prev () {
    read -p 'Input the name of the Docker container you would like to run (PLEASE INSERT IN ALL LOWERCASE): ' name_Docker
    echo '+++++'
    echo 'Running Docker container....'
    echo 'Use CTRL+C to terminate the Docker container at any time.'
    echo 'Access the Docker container by accessing localhost:5000'
    echo '+++++'
    if [ -f ".env" ]
    then
        # FOR /f %%i in ('docker ps -a -q --filter ancestor^=%name_Docker%') DO docker rm --force %%i
        docker run -t -i -p 5000:5000 --env-file .env $name_Docker
        if [ "$?" != "0" ]
        then
            echo 'Unsuccessful in running image. Make sure that you have Docker enabled on your machine.'
            exit
        fi
    else
        # FOR /f %%i in ('docker ps -a -q --filter ancestor^=%name_Docker%') DO docker rm --force %%i
        docker run -t -i -p 5000:5000 $name_Docker  
        if [ "$?" != "0" ]
        then
            echo 'Unsuccessful in running image. Make sure that you have Docker enabled on your machine.'
            exit
        fi
    fi
}

# Setting up local testing for user.
read -p 'Do you want to test locally using Docker? (y/n): ' use_Docker
# Proceeds to the Docker portion.
if [ "$use_Docker" == "y" ]
then
    docker_setup
    exit
# Otherwise, starts the flask container locally by running the 'start.py' script.
elif [ "$use_Docker" == "n" ]
then
    echo '+++++'
    echo 'Starting Flask server locally...'
    echo 'By default, access to the Flask server can be made by making a request to http://localhost:5000'
    echo 'Use CTRL+C to end your flask server if needed.'
    echo '+++++'
    python start.py 
    if [ "$?" != "0" ]
    then
        echo 'Please make sure you have a working version of Python 3 installed on your machine.'
        exit
    fi
fi
exit
