#!/bin/bash

set -e  # exit on a non-zero return code from a command
set -x  # print a trace of commands as they execute

rm -rf .build
mkdir -p .build/symbol-graphs

$(xcrun --find swift) build --target MeshGenerator \
    -Xswiftc -emit-symbol-graph \
    -Xswiftc -emit-symbol-graph-dir -Xswiftc .build/symbol-graphs

$(xcrun --find docc) convert Sources/MeshGenerator/MeshGenerator.docc \
    --analyze \
    --fallback-display-name MeshGenerator \
    --fallback-bundle-identifier com.github.heckj.MeshGenerator \
    --fallback-bundle-version 0.1.0 \
    --additional-symbol-graph-dir .build/symbol-graphs \
    --experimental-documentation-coverage \
    --level brief

# getting coverage with `docbuild`:
# xcodebuild docbuild -scheme SlothCreator \
#     -derivedDataPath ~/Desktop/SlothCreatorBuild \
#     -destination platform=macOS \
#     OTHER_DOCC_FLAGS="--experimental-documentation-coverage --level brief"
