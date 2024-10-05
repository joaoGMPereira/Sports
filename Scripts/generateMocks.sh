#!/bin/sh

# Install sourcery if needed
command -v sourcery >/dev/null 2>&1 || brew install sourcery

# Create temporary folders and arms a trap to remove it at the end
temp_dir=$(mktemp -d)
trap 'rm -Rf -- "$temp_dir"' INT TERM HUP EXIT

input_dir=$temp_dir/input
output_dir=$temp_dir/output
mkdir $input_dir &> /dev/null
mkdir $output_dir &> /dev/null

# Get the input
echo "\nPaste your protocol:"
IFS= read -d '' -s -n 1 input  
echo "\nGenerating mocks...\n" 
while IFS= read -d '' -s -n 1 -t 1 c
do
    input+=$c
done

# Run Sourcery and open the output
echo "${input[@]}" > $input_dir/protocols.swift
sourcery --sources $input_dir --templates ./Scripts/SourceryTemplates/ --output $output_dir
cat $output_dir/AutoMockSpyFake.generated.swift | open -f
