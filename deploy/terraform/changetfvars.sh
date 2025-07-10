#!/bin/sh
BRANCH=$1
DIR=./deploy/terraform/$BRANCH/terraform.tfvars
variablesdir=./deploy/terraform/$BRANCH/variables.tf
while IFS="=" read -r key value
do
  sed -i "s|$key=\"\"|$key=\"${!key}\"|gi" $DIR
done < $DIR
lineNumber=7
counter=0
while IFS="=" read -r key value
do
  counter=$((counter+1))
  envs="$envs $key=\"${!key}\","
done < <(tail -n "+$lineNumber" $DIR)
if [ $counter -gt 0 ]; then
    envs="${envs%?}"
    env_string="ENVS={ $envs }"
    echo $env_string >> $DIR
fi
