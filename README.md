# MeshGenerator

API to generate 3D surface meshes for Apple platforms.

This is a bare-bones library sufficient to create surfaces meshes, and doesn't include tooling or API to generate geometries.
If you're looking for something like that, please look into Nick Lockwood's [Euclid](https://swiftpackageindex.com/nicklockwood/Euclid), which supports generating geometries from paths and text, constructive solid geometry, as well as geometric primitives.

The underlying computations for vectors, normals, etc from this library use [`simd`](https://developer.apple.com/documentation/accelerate/simd) from the [`Acclerate`](https://developer.apple.com/documentation/accelerate) framework.
