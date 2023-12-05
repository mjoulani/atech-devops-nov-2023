#!/bin/bash

# Function for addition
addition() {
    sum=0
    while true; do
        read -p "Enter number to add (OR 0 to stop): " num
        if ! [[ $num =~ ^[0-9]+$ ]]; then
            echo "Please enter a valid number!"
        elif [[ $num -eq 0 ]]; then
            break
        else
            sum=$((sum + num))
        fi
    done
    echo ""
    echo "Result of addition: $sum"
}

# Function for subtraction
subtraction() {
    while true; do
        read -p "Enter the first number: " first_num
        if ! [[ $first_num =~ ^[0-9]+$ ]]; then
            echo "Please enter a valid number!"
        else
            break
        fi
    done

    result=$first_num
    while true; do
        read -p "Enter another  number (OR 0 to stop): " num
        if ! [[ $num =~ ^[0-9]+$ ]]; then
            echo "Please enter a valid number!"
        elif [[ $num -eq 0 ]]; then
            break
        else
            result=$((result - num))
        fi
    done
    echo ""
    echo "Result of subtraction: $result"
}


# Function for multiplication
multiplication() {
    product=1
    while true; do
        read -p "Enter number to multiply (OR 0 to stop): " num
        if ! [[ $num =~ ^[0-9]+$ ]]; then
            echo "Please enter a valid number!"
        elif [[ $num -eq 0 ]]; then
            product=0
            break
        else
            product=$((product * num))
        fi
    done
    echo ""
    echo "Result of multiplication: $product"
}


# Function for division
division() {
    read -p "Enter the first number: " dividend
    while ! [[ $dividend =~ ^[0-9]+$ ]]; do
        echo "Please enter a valid number!"
        read -p "Enter the first number: " dividend
    done

    result=$dividend
    while true; do
        read -p "Enter another number (OR 0 to stop): " num
        if ! [[ $num =~ ^[0-9]+$ ]]; then
            echo "Please enter a valid number!"
        elif [[ $num -eq 0 ]]; then
            echo "Division by zero is not allowed."
        else
            result=$(bc -l <<< "scale=2; $result / $num")
        fi
        if [[ $num -ne 0 ]]; then
            break
        fi
    done
    echo ""
    echo "Result of division: $result"
}

exit_app() {
echo "please wait while exit calculator..."
sleep 1
exit
}

# Display the options
while true; do
echo ""
echo "press Enter to continue!"
# hld is a used to hold screen with the result until next play
read hld
clear
echo "Choose operation:"
echo "----------------"
echo "1. Addition"
echo "2. Subtraction"
echo "3. Multiplication"
echo "4. Division"
echo "5. Exit (5)"

# Read user's choice
read -p "Enter your choice (1-5): " choice

# Perform operation based on user's choice
case $choice in
    1) addition ;;
    2) subtraction ;;
    3) multiplication ;;
    4) division ;;
    5) exit_app ;;
    *) echo "Invalid choice! Please enter a number between 1 and 5" ;;
esac

done
fi
