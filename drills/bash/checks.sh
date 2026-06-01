#!/bin/bash

#input validaton if input is a number

read -p "enter age: " age
if [[ "$age" =~ [0-9]+$ ]]; then
echo "Valid age"
else
echo "Please enter numbers only"
fi

# validating a range

read -p "Enter marks (0-100): " marks
if [[ "$marks" =~ ^[0-9]+$ ]] && (( marks >= 0 && marks <= 100 )); then
echo "valid marks"
else
echo "invalid marks"
fi

# validating yes/no

read -p "continue? (y/n): " choice

case "$choice" in
y|Y)
echo "continuing..."
;;
n|N)
echo "Existing..."
;;
*)
echo "Invalid choice"
;;
esac


# Retrying until a valid input
while true
do
read -p "Enter your age: " age

if [[ "$age" =~ ^[0-9]+$ ]]; then
break
else 
echo "Numbers only"
fi
done

echo "Age is $age"