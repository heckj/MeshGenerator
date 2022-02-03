//
//  MeshGenerator+RealityKit.swift
//
//
//  Created by Joseph Heck on 2/3/22.
//  Portions of this code created by Max Cobb on 12/06/2021, used under license:
//
//  (source reference for original: https://github.com/maxxfrazer/RealityGeometries/)
//
//  Copyright (c) 2020 Max F Cobb
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#if canImport(RealityKit)
    import RealityKit

    @available(macOS 12.0, iOS 15.0, *)
    public extension Array where Element == Vertex {
        /// Generates a mesh descriptor collection for the set of vertices that you provide
        /// - Parameters:
        ///   - indices: The index locations that make up the triangles associated with the collection of vertices.
        ///   - materials: The materials associated with the vertices.
        ///
        ///  You can create a mesh with shared vertices and smoothed normals using generateMeshDescriptor, by providing
        ///  a complete list of the vertices to be used, and the corresponding (typically larger) array of indices that make up the
        ///  triangles within the mesh.
        func generateMeshDescriptor(
            with indices: [UInt32], materials: [UInt32] = []
        ) -> MeshDescriptor {
            var meshDescriptor = MeshDescriptor()
            var positions: [SIMD3<Float>] = []
            var normals: [SIMD3<Float>] = []
            var uvs: [SIMD2<Float>] = []
            for vertex in self {
                positions.append(vertex.position.simd_float3)
                normals.append(vertex.normal.simd_float3)
                uvs.append(vertex.tex.simd_float2)
            }
            meshDescriptor.positions = MeshBuffers.Positions(positions)
            meshDescriptor.normals = MeshBuffers.Normals(normals)
            meshDescriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvs)
            meshDescriptor.primitives = .triangles(indices)
            if !materials.isEmpty {
                meshDescriptor.materials = MeshDescriptor.Materials.perFace(materials)
            }
            return meshDescriptor
        }
    }

    @available(macOS 12.0, iOS 15.0, *)
    public extension Triangle {
        /// Generates a mesh descriptor for the triangle.
        ///
        ///  The vertices of each triangle are represented individually.
        ///  Using this method against a single triangle, or a collection, doesn't
        ///  consolidate the vertices by location and/or normal.
        func generateMeshDescriptor() -> MeshDescriptor {
            var meshDescriptor = MeshDescriptor()
            var positions: [SIMD3<Float>] = []
            var normals: [SIMD3<Float>] = []
            var uvs: [SIMD2<Float>] = []
            for vertex in vertices {
                positions.append(vertex.position.simd_float3)
                normals.append(vertex.normal.simd_float3)
                uvs.append(vertex.tex.simd_float2)
            }
            meshDescriptor.positions = MeshBuffers.Positions(positions)
            meshDescriptor.normals = MeshBuffers.Normals(normals)
            meshDescriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvs)

            let indices: [UInt32] = [0, 1, 2]
            meshDescriptor.primitives = .triangles(indices)

            // TODO: figure out how to map the materials
            // into the mesh descriptor structure...
            // \/ is a material index - so I'll need something to map/link to the actual material here...
            if material != nil {
                let materials: [UInt32] = [0]
                meshDescriptor.materials = MeshDescriptor.Materials.perFace(materials)
            }
            return meshDescriptor
        }
    }

    @available(macOS 12.0, iOS 15.0, *)
    public extension Mesh {
        // extend Mesh and enable something that creates a MeshResource, or ModelComponent?
        // or extend MeshResource and implement a
        // static func generate(from descriptors: [MeshDescriptor]) throws -> MeshResource
        // That takes a Mesh... The Euclid pattern that Nick tended to use was making initializers
        // on the target framework.
        
        // leaning into expanding on Mesh when RealityKit
        // is in play so that we can leverage RealityKit's
        // generate(from:) or generateAsync(from:)
        
        
        /// Returns a list of RealityKit mesh descriptors for use in generating a mesh resource.
        ///
        /// For example:
        /// ```
        /// let positions: [Vector] = [
        ///     Vector(x: 0.5, y: -0.4330127, z: -0.4330127), // 0
        ///     Vector(x: -0.5, y: -0.4330127, z: -0.4330127), // /// 1
        ///     Vector(x: 0, y: 0.4330127, z: 0), // 2  (peak)
        ///     Vector(x: 0, y: -0.4330127, z: 0.4330127), // 3
        /// ]
        ///
        /// let back = Triangle(positions[0], positions[1], positions[2], material: ColorRepresentation.red)
        /// let bottom = Triangle(positions[0], positions[3], positions[1], material: ColorRepresentation.white)
        /// let left = Triangle(positions[0], positions[2], positions[3], material: ColorRepresentation.blue)
        /// let right = Triangle(positions[2], positions[1], positions[3], material: ColorRepresentation.green)
        /// let mesh = Mesh([back, bottom, left, right])
        /// ```
        /// and then...
        /// ```
        /// let resource = MeshResource.generate(mesh.descriptors)
        var descriptors: [MeshDescriptor] {
            return polygons.map { tri in
                tri.generateMeshDescriptor()
            }
        }
    }
#endif
