#!/bin/bash

NAME="Ayush" #no space after equal sign
AGE=19 #stil interpreted as text

echo "$NAME is $[AGE+3] years old"

# Bash doesnt have strong data types

# string spliltting
TODAY=$(date +%Y-%m-%d)
echo $TODAY


# printf (preffered over echo for bash scripting for better predictability and formating support)
# printf "format" arguements...

printf "Hey, Bash!\n"
printf "Hello %s\n" "$NAME" # % : string
printf "Name: %s, Age: %d\n" "$NAME" "$AGE" # %d : Integer
# %f :	Floating-point number
# %x :	Hexadecimal
# %% :	Literal %

printf "CPU Usage : %d%%\n" 55

# colors in CI output
printf "\033[32mSUCCESS\033[0m\n"
printf "\033[31mFAILED\033[0m\n"

# 32 = green
# 31 = red
# 0 = reset

#  storing output as variable
printf -v msg "data scanned: %d%%" 33
echo "$msg"

