#!/bin/bash

echo "Enter the first number:"
read num1

echo "Enter the second number:"
read num2

# Check for numeric input

    print('Disconnecting from database..')
    time.sleep(3)
    print('Successfully disconnected from db')
    print('Performing other cleanup tasks...')
    time.sleep(7)
    sys.exit(0)


signal.signal(signal.SIGINT, signal_handler)
print(f'Server is running
if [[ ! $num1 =~ ^[0-9]+$ || ! $num2 =~ ^[0-9]+$ ]]; then
  echo "Please enter only numbers."
  exit 1
fi


# Calculate the sum
sum=$((num1 + num2))

echo "The sum of numbers $num1 and $num2 is $sum."
