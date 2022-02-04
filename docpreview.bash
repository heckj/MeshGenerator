#!/bin/bash

echo "Make sure you've rebased over the current HEAD branch:"
echo "git rebase -i origin/main docs"

set -e
set -x

rm -rf .build
mkdir -p .build/symbol-graphs

swift build --target MeshGenerator \
-Xswiftc -emit-symbol-graph \
-Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs

xcrun docc convert Sources/MeshGenerator/MeshGenerator.docc \
--analyze \
--fallback-display-name MeshGenerator \
--fallback-bundle-identifier com.github.heckj.MeshGenerator \
--fallback-bundle-version 0.1.0 \
--additional-symbol-graph-dir .build/symbol-graphs \
--experimental-documentation-coverage \
--level brief

xcrun docc preview Sources/MeshGenerator/MeshGenerator.docc \
--fallback-display-name MeshGenerator \
--fallback-bundle-identifier com.github.heckj.MeshGenerator \
--fallback-bundle-version 0.1.0 \
--additional-symbol-graph-dir .build/symbol-graphs
