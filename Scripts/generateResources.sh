echo "\nGenerating source files with Swiftgen and Sourcery"

# Cleanup any generated from git index
find . -iname "*.generated.swift" -exec git rm --cached --ignore-unmatch {} \+

# Run on main projects first as their structure is not the same as modules
mkdir -p Packages/ZenithCore/Sources/ZenithCore/Generated
# Change directory to where the swiftgen.yml is located
cd "$PWD/Packages/ZenithCore" || exit
swiftgen config run --config swiftgen.yml > /dev/null

# Wait on all processes, a process may not exist anymore when getting here, so test for it first
echo "Done"
