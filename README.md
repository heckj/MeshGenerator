# MeshGenerator

API to generate 3D surface meshes for Apple platforms.

- [API documentation](https://heckj.github.io/MeshGenerator/documentation/meshgenerator/)  

This is a bare-bones library sufficient to create surfaces meshes, and doesn't include tooling or API to generate geometries.
The library is intended to be the bare components needed for a useful API that can be used to generate geometries.

The underlying computations for vectors, normals, etc from this library use [`simd`](https://developer.apple.com/documentation/accelerate/simd) from the [`Accelerate`](https://developer.apple.com/documentation/accelerate) framework, if available.

The code owes inspiration, and considerable debt, to Nick Lockwood, creator of [Euclid](https://swiftpackageindex.com/nicklockwood/Euclid). 
Portions of the code are used, under license, from the Euclid project.

The library supports only triangles as a base type of polygon for rendering into geometries. If you want to work with quads or higher order polygons, or use constructive solid geometry, please look into [Euclid](https://swiftpackageindex.com/nicklockwood/Euclid), which supports generating geometries from paths and text, constructive solid geometry, as well as geometric primitives.
