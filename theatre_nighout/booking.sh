#!/bin/bash


show_name=$1
seat_number=$2

rm "$show_name/$seat_number" && echo "Seat $seat_number for $show_name has been booked!" || echo "Error: Seat $seat_number for $show_name is already booked!"
