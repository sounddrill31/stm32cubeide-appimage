#!/usr/bin/bash

# Dummy script for now, just shows the files in the input directory
INPUT_PATH=$(dirname $(readlink -f $0))

echo "Setting up STM32Cube environment..."
echo "Displaying contents of the input directory: $INPUT_PATH"
ls -l $INPUT_PATH
tree $INPUT_PATH

# echo "Extracting script from input directory..."
# echo "Extracting STM32Cube files..."
# echo "STM32Cube environment setup complete."