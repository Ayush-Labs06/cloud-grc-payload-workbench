#!/bin/bash

NAME="Ayush" #no space after equal sign
AGE=19 #stil interpreted as text

echo "$NAME is $[AGE+3] years old"

# Bash doesnt have strong data types

# string spliltting
TODAY=$(date +%Y-%m-%d)
echo $TODAY