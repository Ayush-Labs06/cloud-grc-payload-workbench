#!/bin/bash

# for loop
for num in 1 2 3
do
echo "$num: sheep"
done

for file in $(ls)
do
    echo "$file"
done

for (( i=0; i<6; i++ )); do
echo "$i"
done 


# while loops
AGE=22
ADULT=18
while (( ADULT <= AGE ))
do
echo "the gap years are: $ADULT"
(( ADULT++ ))
done
