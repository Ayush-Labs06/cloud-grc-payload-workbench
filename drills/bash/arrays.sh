#!/bin/bash

users=("ayush" "lukas" "kakashi")

echo "${users[0]}" # ayush
echo "${users[1]}" # lukas

echo "${users[@]}" # whole array
echo "${#users[@]}" # length array

# Looping through array

for user in "${users[@]}"
do
echo "username: $user"
done

# To add new element
users+=("jackob")
echo "${users[@]}"

# To change a element
users[3]="nick"
echo "${users[@]}"

