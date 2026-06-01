#!/bin/bash

greet() {    #function
    echo "your name?"
    read user
    echo "welcome back $user" 
}

greet # calling function

# functions with parameter
hello() {
    echo "Hello $1"
}

hello Ayush

# Multiple parameter
user_info() {
    echo "your name is $1 with age $2"
    echo "PII: $@"
}

user_info Ayusz 22


# Local block : scope variables to functions block
hokage() {
    local Name="Kakashi"
    echo "$Name"
}

hokage #ouput kakashi
echo "$Name" # Doesnt output anything as Name variable is scoped to hokage function


# return 0 = success
# return 1 = failure