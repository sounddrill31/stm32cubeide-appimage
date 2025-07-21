#!/usr/bin/bash

# Dummy script for now, just shows the files in the input directory
echo "Preparing Script"
echo "Input: $0"
echo "Output Folder: $1"

echo "Setting up STM32Cube environment..."
echo "Displaying contents of the input directory: $0"
ls -lh $0
tree $0


# echo "Extracting script from input directory..."
# echo "Extracting STM32Cube files..."
# echo "STM32Cube environment setup complete."