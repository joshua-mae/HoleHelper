#!/bin/bash

username=$(whoami)
folder_dir=$(find /home/$username -type d -name "HH-Results" ! -path "/home/*/*.*")
logs_folder="$folder_dir/logs-folder"
inp_folder="$folder_dir/inp-folder"
for inp_file in $inp_folder/*;
do 
    full_filename=$(basename $inp_file)
    file="${full_filename%.*}"

    hole < $inp_file >> "$logs_folder/$file.log"
done