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