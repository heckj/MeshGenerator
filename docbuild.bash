#!/bin/bash

echo "Make sure you've rebased over the current HEAD branch:"
echo "git rebase -i origin/main docs"

set -e  # exit on a non-zero return code from a command
set -x  # print a trace of commands as they execute

# rm -rf .build
# mkdir -p .build/symbol-graphs

# $(xcrun --find swift) build --target MeshGenerator \
#     -Xswiftc -emit-symbol-graph \
#     -Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs

# Enables deterministic output 
# - useful when you're committing the results to host on github pages
export DOCC_JSON_PRETTYPRINT=YES

# $(xcrun --find docc) convert Sources/MeshGenerator/MeshGenerator.docc \
#     --output-path ./docs \
#     --fallback-display-name MeshGenerator \
#     --fallback-bundle-identifier com.github.heckj.MeshGenerator \
#     --fallback-bundle-version 0.1.0 \
#     --additional-symbol-graph-dir .build/symbol-graphs \
#     --emit-digest \
#     --transform-for-static-hosting \
#     --hosting-base-path 'MeshGenerator'

# Swift package plugin for hosted content:
#
$(xcrun --find swift) package \
    --allow-writing-to-directory ./docs \
    generate-documentation \
    --fallback-bundle-identifier com.github.heckj.MeshGenerator \
    --target MeshGenerator \
    --output-path ./docs \
    --emit-digest \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path 'MeshGenerator'

# Generate a list of all the identifiers to assist in DocC curation
#

cat docs/linkable-entities.json | jq '.[].referenceURL' -r > all_identifiers.txt
sort all_identifiers.txt \
    | sed -e 's/doc:\/\/com\.github\.heckj\.MeshGenerator\/documentation\///g' \
    | sed -e 's/^/- ``/g' \
    | sed -e 's/$/``/g' > all_symbols.txt

echo "Page will be available at https://heckj.github.io/MeshGenerator/documentation/meshgenerator/"

# xcodebuild docbuild -scheme ExampleDocC \
#     -destination generic/platform=iOS \
#     OTHER_DOCC_FLAGS="--transform-for-static-hosting --hosting-base-path <hosting-base-path>" \
#     DOCC_OUTPUT_DIR=./docs

# equivalent to:
# xcodebuild docbuild -scheme ExampleDocC \
#     -destination generic/platform=iOS \
#     OTHER_DOCC_FLAGS="--transform-for-static-hosting --hosting-base-path ExampleDocC --output-path docs"
