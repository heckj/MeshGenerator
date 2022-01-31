//
//  MeshGenerator+SceneKit.swift
//
//
//  Created by Nick Lockwood on 03/07/2018.
//  Copyright © 2018 Nick Lockwood. All rights reserved.
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/Euclid
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
//

#if canImport(SceneKit)

    import SceneKit

    public extension SCNVector3 {
        init(_ v: Vector) {
            self.init(v.x, v.y, v.z)
        }
    }

    private extension Data {
        mutating func append(_ int: UInt32) {
            var int = int
            withUnsafeMutablePointer(to: &int) { pointer in
                append(UnsafeBufferPointer(start: pointer, count: 1))
            }
        }

        mutating func append(_ double: Double) {
            var float = Float(double)
            withUnsafeMutablePointer(to: &float) { pointer in
                append(UnsafeBufferPointer(start: pointer, count: 1))
            }
        }

        mutating func append(_ vector: Vector) {
            append(vector.x)
            append(vector.y)
            append(vector.z)
        }
    }

    #if canImport(UIKit)
        private typealias OSColor = UIColor
        private typealias OSImage = UIImage
    #elseif canImport(AppKit)
        private typealias OSColor = NSColor
        private typealias OSImage = NSImage
    #endif

    private func defaultMaterialLookup(_ material: Triangle.Material?) -> SCNMaterial? {
        switch material {
        case let material as SCNMaterial:
            return material
        case let color as ColorRepresentation:
            let material = SCNMaterial()
            material.diffuse.contents = OSColor(color)
            return material
        case let color as OSColor:
            let material = SCNMaterial()
            material.diffuse.contents = color
            return material
        case let image as OSImage:
            let material = SCNMaterial()
            material.diffuse.contents = image
            return material
        default:
            return nil
        }
    }

    public extension SCNGeometry {
        typealias SCNMaterialProvider = (Triangle.Material?) -> SCNMaterial?

        /// Creates an SCNGeometry using the default tessellation method
        convenience init(_ mesh: Mesh, materialLookup: SCNMaterialProvider? = nil) {
            self.init(triangles: mesh, materialLookup: materialLookup)
        }

        /// Creates an SCNGeometry from a Mesh using triangles
        convenience init(triangles mesh: Mesh, materialLookup: SCNMaterialProvider? = nil) {
            var elementData = [Data]()
            var vertexData = Data()
            var materials = [SCNMaterial]()
            var indicesByVertex = [Vertex: UInt32]()
            let materialLookup = materialLookup ?? defaultMaterialLookup
            for (material, polygons) in mesh.polygonsByMaterial {
                var indexData = Data()
                func addVertex(_ vertex: Vertex) {
                    if let index = indicesByVertex[vertex] {
                        indexData.append(index)
                        return
                    }
                    let index = UInt32(indicesByVertex.count)
                    indicesByVertex[vertex] = index
                    indexData.append(index)
                    vertexData.append(vertex.position)
                    vertexData.append(vertex.normal)
                    vertexData.append(vertex.tex.u)
                    vertexData.append(vertex.tex.v)
                }
                materials.append(materialLookup(material) ?? SCNMaterial())
                for polygon in polygons {
                    polygon.vertices.forEach(addVertex)
                }
                elementData.append(indexData)
            }
            let vertexStride = 12 + 12 + 8
            let vertexCount = vertexData.count / vertexStride
            self.init(
                sources: [
                    SCNGeometrySource(
                        data: vertexData,
                        semantic: .vertex,
                        vectorCount: vertexCount,
                        usesFloatComponents: true,
                        componentsPerVector: 3,
                        bytesPerComponent: 4,
                        dataOffset: 0,
                        dataStride: vertexStride
                    ),
                    SCNGeometrySource(
                        data: vertexData,
                        semantic: .normal,
                        vectorCount: vertexCount,
                        usesFloatComponents: true,
                        componentsPerVector: 3,
                        bytesPerComponent: 4,
                        dataOffset: 12,
                        dataStride: vertexStride
                    ),
                    SCNGeometrySource(
                        data: vertexData,
                        semantic: .texcoord,
                        vectorCount: vertexCount,
                        usesFloatComponents: true,
                        componentsPerVector: 2,
                        bytesPerComponent: 4,
                        dataOffset: 24,
                        dataStride: vertexStride
                    ),
                ],
                elements: elementData.map { indexData in
                    SCNGeometryElement(
                        data: indexData,
                        primitiveType: .triangles,
                        primitiveCount: indexData.count / 12,
                        bytesPerIndex: 4
                    )
                }
            )
            self.materials = materials
        }

        /// Creates an SCNGeometry from a Mesh using convex polygons
        @available(OSX 10.12, iOS 10.0, tvOS 10.0, *)
        convenience init(polygons mesh: Mesh, materialLookup: SCNMaterialProvider? = nil) {
            var elementData = [(Int, Data)]()
            var vertexData = Data()
            var materials = [SCNMaterial]()
            var indicesByVertex = [Vertex: UInt32]()
            let materialLookup = materialLookup ?? defaultMaterialLookup
            for (material, polygons) in mesh.polygonsByMaterial {
                var indexData = Data()
                func addVertex(_ vertex: Vertex) {
                    if let index = indicesByVertex[vertex] {
                        indexData.append(index)
                        return
                    }
                    let index = UInt32(indicesByVertex.count)
                    indicesByVertex[vertex] = index
                    indexData.append(index)
                    vertexData.append(vertex.position)
                    vertexData.append(vertex.normal)
                    vertexData.append(vertex.tex.u)
                    vertexData.append(vertex.tex.v)
                }
                materials.append(materialLookup(material) ?? SCNMaterial())
//            let polygons = polygons.tessellate()
                for polygon in polygons {
                    indexData.append(UInt32(polygon.vertices.count))
                }
                for polygon in polygons {
                    polygon.vertices.forEach(addVertex)
                }
                elementData.append((polygons.count, indexData))
            }
            let vertexStride = 12 + 12 + 8
            let vertexCount = vertexData.count / vertexStride
            self.init(
                sources: [
                    SCNGeometrySource(
                        data: vertexData,
                        semantic: .vertex,
                        vectorCount: vertexCount,
                        usesFloatComponents: true,
                        componentsPerVector: 3,
                        bytesPerComponent: 4,
                        dataOffset: 0,
                        dataStride: vertexStride
                    ),
                    SCNGeometrySource(
                        data: vertexData,
                        semantic: .normal,
                        vectorCount: vertexCount,
                        usesFloatComponents: true,
                        componentsPerVector: 3,
                        bytesPerComponent: 4,
                        dataOffset: 12,
                        dataStride: vertexStride
                    ),
                    SCNGeometrySource(
                        data: vertexData,
                        semantic: .texcoord,
                        vectorCount: vertexCount,
                        usesFloatComponents: true,
                        componentsPerVector: 2,
                        bytesPerComponent: 4,
                        dataOffset: 24,
                        dataStride: vertexStride
                    ),
                ],
                elements: elementData.map { count, indexData in
                    SCNGeometryElement(
                        data: indexData,
                        primitiveType: .polygon,
                        primitiveCount: count,
                        bytesPerIndex: 4
                    )
                }
            )
            self.materials = materials
        }

        /// Creates a wireframe SCNGeometry from a collection of LineSegments
        convenience init<T: Collection>(_ edges: T) where T.Element == LineSegment {
            var indexData = Data()
            var vertexData = Data()
            var indicesByVertex = [Vector: UInt32]()
            func addVertex(_ vertex: Vector) {
                if let index = indicesByVertex[vertex] {
                    indexData.append(index)
                    return
                }
                let index = UInt32(indicesByVertex.count)
                indicesByVertex[vertex] = index
                indexData.append(index)
                vertexData.append(vertex)
            }
            for edge in edges {
                addVertex(edge.start)
                addVertex(edge.end)
            }
            self.init(
                sources: [
                    SCNGeometrySource(
                        data: vertexData,
                        semantic: .vertex,
                        vectorCount: vertexData.count / 12,
                        usesFloatComponents: true,
                        componentsPerVector: 3,
                        bytesPerComponent: 4,
                        dataOffset: 0,
                        dataStride: 0
                    ),
                ],
                elements: [
                    SCNGeometryElement(
                        data: indexData,
                        primitiveType: .line,
                        primitiveCount: indexData.count / 8,
                        bytesPerIndex: 4
                    ),
                ]
            )
        }

        /// Creates a wireframe SCNGeometry from a Mesh using line segments
        convenience init(wireframe mesh: Mesh) {
            self.init(mesh.uniqueEdges)
        }

        /// Creates line-segment SCNGeometry representing the vertex normals of a Mesh
        convenience init(normals mesh: Mesh, scale: Double = 1) {
            self.init(Set(mesh.polygons.flatMap { $0.vertices }.compactMap {
                LineSegment($0.position, $0.position + $0.normal * scale)
            }))
        }

        /// Creates a line-segment bounding-box SCNGeometry from a Bounds
        convenience init(_ bounds: Bounds) {
            var vertexData = Data()
            let corners = [
                bounds.min,
                Vector(bounds.min.x, bounds.max.y, bounds.min.z),
                Vector(bounds.max.x, bounds.max.y, bounds.min.z),
                Vector(bounds.max.x, bounds.min.y, bounds.min.z),
                Vector(bounds.min.x, bounds.min.y, bounds.max.z),
                Vector(bounds.min.x, bounds.max.y, bounds.max.z),
                bounds.max,
                Vector(bounds.max.x, bounds.min.y, bounds.max.z),
            ]
            for origin in corners {
                vertexData.append(origin)
            }
            let indices: [UInt32] = [
                // bottom
                0, 1, 1, 2, 2, 3, 3, 0,
                // top
                4, 5, 5, 6, 6, 7, 7, 4,
                // columns
                0, 4, 1, 5, 2, 6, 3, 7,
            ]
            var indexData = Data()
            indices.forEach { indexData.append($0) }
            self.init(
                sources: [
                    SCNGeometrySource(
                        data: vertexData,
                        semantic: .vertex,
                        vectorCount: vertexData.count / 8,
                        usesFloatComponents: true,
                        componentsPerVector: 3,
                        bytesPerComponent: 4,
                        dataOffset: 0,
                        dataStride: 0
                    ),
                ],
                elements: [
                    SCNGeometryElement(
                        data: indexData,
                        primitiveType: .line,
                        primitiveCount: indexData.count / 8,
                        bytesPerIndex: 4
                    ),
                ]
            )
        }
    }

    // MARK: import

    private extension Data {
        func index(at index: Int, bytes: Int) -> UInt32 {
            switch bytes {
            case 1: return UInt32(self[index])
            case 2: return UInt32(uint16(at: index * 2))
            case 4: return uint32(at: index * 4)
            default: preconditionFailure()
            }
        }

        func uint16(at index: Int) -> UInt16 {
            var int: UInt16 = 0
            withUnsafeMutablePointer(to: &int) { pointer in
                copyBytes(
                    to: UnsafeMutableBufferPointer(start: pointer, count: 1),
                    from: index ..< index + 2
                )
            }
            return int
        }

        func uint32(at index: Int) -> UInt32 {
            var int: UInt32 = 0
            withUnsafeMutablePointer(to: &int) { pointer in
                copyBytes(
                    to: UnsafeMutableBufferPointer(start: pointer, count: 1),
                    from: index ..< index + 4
                )
            }
            return int
        }

        func float(at index: Int) -> Double {
            var float: Float = 0
            withUnsafeMutablePointer(to: &float) { pointer in
                copyBytes(
                    to: UnsafeMutableBufferPointer(start: pointer, count: 1),
                    from: index ..< index + 4
                )
            }
            return Double(float)
        }

        func vector(at index: Int) -> Vector {
            Vector(
                float(at: index),
                float(at: index + 4),
                float(at: index + 8)
            )
        }
    }

    public extension Vector {
        /// Creates a new vector from the SceneKit vector.
        /// - Parameter v: The SceneKit vector.
        init(_ v: SCNVector3) {
            self.init(Double(v.x), Double(v.y), Double(v.z))
        }
    }

    public extension Bounds {
        init(_ scnBoundingBox: (min: SCNVector3, max: SCNVector3)) {
            self.init(min: Vector(scnBoundingBox.min), max: Vector(scnBoundingBox.max))
        }
    }

    public extension Mesh {
        typealias MaterialProvider = (SCNMaterial) -> Material?
    }

#endif
