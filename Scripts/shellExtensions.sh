export ROOT_PATH="$(git rev-parse --show-toplevel)"

fileExists() {
    local file="$1"
    test -f "$file"
}

isInMergeState() {
    fileExists "$ROOT_PATH/MERGE_HEAD"
}

isSwiftFile() {
    local filename="${1}"
    [[ "${filename##*.}" == "swift" ]]
}

areThereModifiedFiles() {
    test -n "$(git status --porcelain)"
}

areThereUnpushedCommits() {
    test -n "$(git cherry -v)"
}