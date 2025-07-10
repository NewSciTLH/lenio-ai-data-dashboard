# Script that lists environment variables from `envs.txt`.
COUNT=1

if [ ! -f ".env" ]
then
    echo 'No environment variables specified... .env file does not exist.'
    exit
fi

if [ "$1" == "keys" ]
then
    # echo -----
    # echo Here are the current keys for your environment variables:
    # echo -----
    while IFS="=" read -r key value
    do
        echo $COUNT: $key
        COUNT=$((COUNT+1))
    done < ".env"
fi

if [ "$1" == "all" ]
then
    # echo -----
    # echo Here are all environment variables (key=value) from the file:
    # echo -----
    while IFS="=" read -r key value
    do
        echo $COUNT: $key=$value
        COUNT=$((COUNT+1))
    done < ".env"
fi
