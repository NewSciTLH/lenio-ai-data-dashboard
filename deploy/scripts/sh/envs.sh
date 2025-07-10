#!/bin/bash
# Script that adds environment variables to .env file for ingestion into Cloud Build/Terraform

# Begins addition process of environment variables.
add () {
    read -p 'Please input the key of the variable: ' key
    key=${key^^}
    read -p 'Please input the value of the variable: ' value
    pair="$key=$value"
    while IFS= read -r line
    do
        echo $line >> .newenv
    done < ".env"
    echo $pair >> .newenv
    cp ".newenv" ".env"
    rm ".newenv"
    echo 'Environment variable added.'
    echo 'To apply this variable update to your remote deployment, you must update the cloud build trigger.'
    read -p 'Would you like to add another environment variable? (y/n): ' choice
    if [ "$choice" == "y" ]
    then
        add
    fi
    echo 'Returning to menu...'
    menu
}

# Begins deletion process of environment variables.
delete () {
    echo 'Here are the keys for the currently implemented environment variables:'
    echo '-----'
    . deploy/scripts/sh/listenvs.sh keys
    echo '0: Return to environment variables menu. [COMMAND NOT ENV VAR]'

    echo 'Which environment variable would you like to remove?'
    read -p 'Please type in the number corresponding to the key: ' keynum
    if ! [ "$keynum" -eq "$keynum" ] 2> /dev/null
    then
        echo 'Returning to menu...'
        menu
    elif [ "$keynum" == "0" ]
    then
        echo 'Returning to menu...'
        menu
    fi
    COUNT=1
    touch .newenv
    while IFS="" read -r line
    do
        if [ "$COUNT" != "$keynum" ]
        then
            echo $line >> .newenv
        fi
        COUNT=$((COUNT+1)) 
    done < ".env"
    cp ".newenv" ".env"
    rm ".newenv"
    echo 'To apply this variable update to your remote deployment, you must update the cloud build trigger.'
    delete
}

# Begins editing process of already-existing environment variables.
edit () {
    echo 'Here are the keys for the currently implemented environment variables:'
    echo '-----'
    . deploy/scripts/sh/listenvs.sh all
    echo '0: Return to environment variables menu. [COMMAND NOT ENV VAR]'

    echo 'Which environment variable would you like to edit?'
    read -p 'Please type in the number corresponding to the key: ' keynum
    if ! [ "$keynum" -eq "$keynum" ] 2> /dev/null
    then
        echo 'Returning to menu...'
        menu
    elif [ "$keynum" == "0" ]
    then
        echo 'Returning to menu...'
        menu
    fi
    read -p 'Please enter the new value of this variable: ' editvalue
    COUNT=1
    # touch .newenv
    while IFS= read -r line
    do
        if [ "$COUNT" != "$keynum" ]
        then
            echo $line >> .newenv
        elif [ "$COUNT" == "$keynum" ]
        then
            while IFS="=" read -r key value
            do
                newpair="$key=$editvalue"
                echo $newpair >> .newenv
            done <<< "$line"
            echo $line
        fi
        COUNT=$((COUNT+1))
    done < ".env"
    cp ".newenv" ".env"
    rm ".newenv"
    echo 'To apply this variable update to your remote deployment, you must update the cloud build trigger.'
    edit
}

# Environment Variables menu
menu () { 
    echo 'Input the corresponding number to select an option:'
    echo '1: Add Environment Variable'
    echo '2: Edit Environment Variable'
    echo '3: Delete Environment Variable'
    echo '0: Exit Application '
    read -p 'Option: ' option
    echo '-----'
    # Conditional if the user wants to test locally.
    if [ "$option" == "1" ]
    then
        echo 'Environment variables are represented as a key-value pair. THE KEY MUST BE IN UPPERCASE FORM.'
        echo 'Ex. "Key=value"'
        add
    # Conditional if the user wants to setup autodeployment using Cloud Build
    elif [ "$option" == "2" ]
    then
        edit
    elif [ "$option" == "3" ]
    then
        delete
    # Conditional if user exits application.
    elif [ "$option" == "0" ]
    then
        echo 'Exiting application...'
        exit
    fi
    exit
}

echo '++++'
echo 'Environment Variable control'
echo '++++'

# Checks environment variables file if it exists.
if [ -f ".env" ]
then
  echo 'File `env` already exists. Proceeding to environment variable configuation...'
else
  echo 'Building `env` file for storing environment variables...'
  touch .env
  echo 'You can manually add environment variables to this file, or use this tool to add them yourselves.'
  echo 'Environment variables are represented as a key-value pair.'
  echo 'Ex. "Key=value"'
  echo 'This file will and should only be stored on your local machine. It will not be stored in GitHub/Google Cloud.'
  echo '-----'
fi

echo 'THESE ENVIRONMENT VARIABLES WILL BE EMBEDDED INTO THE DOCKER CONTAINER.'
menu
exit
