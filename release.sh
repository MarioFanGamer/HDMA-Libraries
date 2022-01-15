#!/usr/bin/env sh

release_folder='release'
level_folder='level'
library_folder='library'

scrollable_folder="Scrollable HDMA Gradients"
parallax_folder="Parallax HDMA Toolkit"
waves_folder="Waves HDMA Toolkit"

# If no argument given: Display help.
if [ $# == 0 ]; then
	echo "HDMA Library Release Script"
	echo "Usage: release.sh <action>"
	echo "Where <action> can be:"
	echo " all: Creates a release ZIP for all libraries."
	echo " scroll: Creates a release ZIP of Scrollable HDMA Gradients"
	echo " parallax: Creates a release ZIP of Parallax HDMA Toolkit"
	echo " waves: Creates a release ZIP of Waves HDMA Toolkit"
	exit 0
fi

# If release folder doesn't exist already
if [ ! -d "$release_folder" ]; then
	mkdir "$release_folder"
fi

if [ ! -d "$release_folder/$level_folder" ]; then
	mkdir "$release_folder/$level_folder"
fi

if [ ! -d "$release_folder/$library_folder" ]; then
	mkdir "$release_folder/$library_folder"
fi

# Copy the technical readme to the release folder.
cp "HDMA Libraries - Technical Readme.txt" "$release_folder"

# Now it depends on the options.
case $1 in
	scroll)
		# Just some standardised variable names
		source_folder="$scrollable_folder"
		zip_name="$source_folder"
		
		# Merge BaseMacros.asm with ScrollMacros.asm
		cat BaseMacros.asm "$source_folder/ScrollMacros.asm" > "$release_folder/ScrollMacros.asm"
		
		# Copy all the individual files to the main folder
		cp "$source_folder/Scrollable HDMA Gradient - Readme.txt" "$release_folder"
		cp "$source_folder/Scrollable HDMA Gradient - Technical Readme.txt" "$release_folder"
		
		# Copy the library to the library folder
		cp "$source_folder/ScrollHDMA.asm" "$release_folder/$library_folder"
		
		# Copy base code to the levels folder
		cp "$source_folder/Base.asm" "$release_folder/$level_folder"
		
		# Get every file and copy them to levels (yes, this is the best code I could find)
		find "./$source_folder/examples/" -type f -exec cp '{}' "$release_folder/$level_folder" \;
		;;
	parallax)
		# Just some standardised variable names
		source_folder="$parallax_folder"
		zip_name="$source_folder"
		
		# Merge BaseMacros.asm with ParallaxMacros.asm
		cat BaseMacros.asm "$source_folder/ParallaxMacros.asm" > "$release_folder/ParallaxMacros.asm"
		
		# Copy all the individual files to the main folder
		cp "$source_folder/Parallax HDMA Toolkit - Readme.txt" "$release_folder"
		
		# Copy the library to the library folder
		cp "$source_folder/ParallaxToolkit.asm" "$release_folder/$library_folder"
		
		# Copy base code to the levels folder
		cp "$source_folder/Base.asm" "$release_folder/$level_folder"
		
		# Get every file and copy them to levels
		find "./$source_folder/examples/" -type f -exec cp '{}' "$release_folder/$level_folder" \;
		;;
	waves)
		# Just some standardised variable names
		source_folder="$waves_folder"
		zip_name="$source_folder"
		
		# Merge BaseMacros.asm with WavesMacros.asm
		cat BaseMacros.asm "$source_folder/WavesMacros.asm" > "$release_folder/WavesMacros.asm"
		
		# Copy all the individual files to the main folder
		cp "$source_folder/HDMA Waves Toolkit - Readme.txt" "$release_folder"
		cp "$source_folder/HDMA Waves Toolkit - Technical Readme.txt" "$release_folder"
		
		# Copy the library to the library folder
		cp "$source_folder/WavesToolkit.asm" "$release_folder/$library_folder"
		
		# Copy base code to the levels folder
		cp "$source_folder/Base.asm" "$release_folder/$level_folder"
		
		# Get every file and copy them to levels
		find "./$source_folder/examples/" -type f -exec cp '{}' "$release_folder/$level_folder" \;
		;;
	all)
		echo "Not implemented yet." >&2
		exit 1
		;;
	*)
		echo "Error: Invalid input." >&2
		find "./$release_folder/" ! -type d -exec rm '{}' \;
		exit 1
		;;
esac

# Now create the ZIP
( cd "$release_folder/"; zip -r "../${zip_name}.zip" . )

# Remove every non-folder
find "./$release_folder/" ! -type d -exec rm '{}' \;

# Go figure.
echo 'Release ZIP has been successfully created!'
