#!/bin/bash

for inp_file in $1/HH-Results/inp-folder/*;
do 
    full_filename=$(basename $inp_file)
    file="${full_filename%.*}"

    hole < $inp_file >> "$1/HH-Results/logs-folder/$file.log"
done