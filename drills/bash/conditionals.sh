#!/bin/bash

echo "Enter your age"
read AGE

if (( AGE > 18))
then
echo "Adult"
elif (( AGE == 18))
then
echo "Eligible"
else
echo "minor"
fi 

echo "Enter your name"
read NAME
# ------------------------          ----------------------

if  (( AGE > 18 )) && [[ "$NAME" == "Ayush" || "$NAME" == "AYUSH" || "$NAME" == "ayush" ]] # you can replace with "${NAME,,} == "ayush"
then
echo "You are registered user"
else
echo "you are not registereed"
fi

# ----------------------          --------------------
if [[ "$ENVIRONMENT" == "prod" ]]; then
printf '%s\n' "production rules apply"
elif [[ "$ENVIRONMENT" == "staging" ]]; then
printf '%s\n' "staging rules apply"
else
printf '%s\n' "staging rules apply"
fi





