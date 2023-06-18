#!/bin/bash

selection=$1

result=$(echo $(swww query) | grep -o 'image: "[^"]*"')
result=${result#image: \"}
result=${result%\"}
current_wallpaper=${result%\"}

directory="$HOME/.bin/backgrounds/pngs"

# Step 1: Get the list of files in the directory
files=(~/.bin/backgrounds/pngs/*)

# Step 2: Sort the array of files
sorted_files=($(printf '%s\n' "${files[@]}" | sort -V))

# Step 3: Find the index of the given file name
index=-1

for i in "${!sorted_files[@]}"; do
	if [[ "${sorted_files[$i]}" == "$directory/$current_wallpaper" ]]; then
		index=$i
		break
	fi
done

# Step 4: Determine the next file
next_index=$((index + 1))

if [ $next_index -lt ${#sorted_files[@]} ]; then
	next_file="${sorted_files[$next_index]}"
	if [[ $next_file == *"falling_star.png"* ]]; then
		next_index=$((next_index + 1))
		if [ $next_index -lt ${#sorted_files[@]} ]; then
			next_file="${sorted_files[$next_index]}"
		else
			next_file="${sorted_files[0]}"
		fi
	else
		next_file="${sorted_files[$next_index]}"
	fi
else
	next_file="${sorted_files[0]}" # Roll back to the first file
fi

echo "Setting wallpaper to $next_file"

swww img "$next_file" -t center
