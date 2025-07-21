#!/usr/bin/bash

VERSION=$(cat current_version.txt)

# Dummy script for now, just shows the files in the input directory
echo "Running $0 with arguments: $@"

INPUT=$1
OUTPUT=$2
echo "Preparing Script $INPUT  ..."
echo "Input: $INPUT"
echo "Output Folder: $OUTPUT"

echo "Setting up STM32Cube environment..."
echo "Displaying contents of the input directory: $INPUT"
ls -lh $INPUT
tree $INPUT


echo "Extracting script from input directory..."
mkdir -p prebuilts/${VERSION}/extracted
bash $INPUT --tar xvf -C prebuilts/${VERSION}/extracted && (echo "Finished Extracting! Showing Extracted Files"; tree prebuilts/${VERSION}/extracted) # We know the script has a tarball and a self-extracting command


echo "Installing STM32Cube files to temporary path..."
(
cp scripts/ci_*.sh prebuilts/${VERSION}/extracted/
cd prebuilts/${VERSION}/extracted/
echo "Running ci_install.sh to prepare the AppDir structure..."
bash ci_install.sh --output-prefix AppDir
)

echo "STM32Cube environment setup complete. Showing AppDir structure:"
tree AppDir