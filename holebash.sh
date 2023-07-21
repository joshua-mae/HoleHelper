#!/bin/bash

for inp_file in rad/*;
do 
    file_name=$(basename $inp_file)
    echo $file_name
    # inp_file < hole >> log file
done