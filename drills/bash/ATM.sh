#!/bin/bash

#status
SBI=1
CANRARA=1
PNB=0

#users
userA="ayush"
userAsum=80
userApass="alliswell"

userB="lukas"
userBsum=99
userBpass="bon appetit"

userC="kakashi"
userCsum=49
userCpass="Rasengan"

echo "Enter your userName"
read userN

if [[ ${userN,,} == "$userA" ]]
then
BALANCE=$userAsum && echo "welcome $userA, enter sum you wish to withdraw" 
read WITHDRAW
elif  [[ ${userN,,} == "$userB" ]]
then
BALANCE=$userBsum && echo "welcome $userB, enter sum you wish to withdraw"
read WITHDRAW
elif  [[ ${userN,,} == "$userC" ]]
then
BALANCE=$userCsum && echo "welcome $userC, enter sum you wish to withdraw"
read WITHDRAW

else
echo "Not registered"
exit
fi


if (( WITHDRAW <= BALANCE ))
then
remaining=$(( BALANCE - WITHDRAW ))
echo "your sum have been withdrawn, and remaining balance is '$remaining' "
else
echo "You dont have enough balacne"
fi