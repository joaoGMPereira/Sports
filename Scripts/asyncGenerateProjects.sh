#!/bin/sh

set -e

source Scripts/envVariables.sh

echo "Generating modules projects async"

# Next go all modules async. Modules must not reference other modules .xcodeproj
pids=()
for d in Packages/*/*/; do
    # Run xcodegen in a child process and store the process id to wait its completion later
    [ -f ${d}project.yml ] && xcodegen -q -s ${d}project.yml &
    pids+=($!)
done

# Wait on all processes, a process may not exist anymore when getting here, so test for it first
for pid in "${pids[@]}"; do
   if ps -p $pid > /dev/null
   then
       wait $pid;
   fi
done

echo "Done."

# Finally the main projects that reference everyone

echo "\nGenerating main projects"

xcodegen -q -s KettleGym/project.yml

echo "Done."
