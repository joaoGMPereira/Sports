#!/bin/bash

echo -e "\nGenerating source files with SwiftGen"

# Cleanup any generated files from the git index
find . -iname "*.generated.swift" -exec git rm --cached --ignore-unmatch {} \+

# Define an array of paths where SwiftGen should run
paths=(
  "Packages/ZenithCore"
  "Packages/Zenith"
)

for path in "${paths[@]}"; do
  echo "Running SwiftGen in: $path"

  # Ensure the output directory exists
  mkdir -p "$path/Sources/$(basename "$path")/Generated"

  # Move to the directory to run SwiftGen
  cd "$path" || exit 1

  # Run SwiftGen
  swiftgen config run --config swiftgen.yml > /dev/null

  # Return to root directory
  cd - > /dev/null
done

echo "Done"
