#!/usr/bin/env bash

set -e

exit_code=0

fixture_dir="${0%/*}/fixtures"

tests=( $(ls "$fixture_dir") )

for test in "${tests[@]}"; do
    set -a
    . "$fixture_dir/$test/.env"
    set +a

    expected=$(< "$fixture_dir/$test/output.txt")

    actual=$(zig build run < "$fixture_dir/$test/input.txt")

    if [[ "$expected" != "$actual" ]]; then
        echo "Expected output to match:"
        diff <( echo "$expected" ) <( echo "$actual" )
        exit_code=1
    fi
done

if [[ $exit_code == 0 ]]; then
    echo "All tests passed"
fi

exit $exit_code



