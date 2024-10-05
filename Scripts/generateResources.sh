echo "\nGenerating source files with Swiftgen and Sourcery"

# Cleanup any generated from git index
find . -iname "*.generated.swift" -exec git rm --cached --ignore-unmatch {} \+

# Run on main projects first as their structure is not the same as modules
mkdir -p Sports/Generated
swiftgen config run --config swiftgen.yml > /dev/null

# Wait on all processes, a process may not exist anymore when getting here, so test for it first
echo "Done"
