//
//  MeshGenerationTests.swift
//
//
//  Created by Joseph Heck on 2/3/22.
//

#if os(tvOS) || os(watchOS)
#else
    import MeshGenerator
    import RealityKit
    import XCTest

    @available(macOS 12.0, iOS 15.0, *)
    class MeshGenerationTests: XCTestCase {
        #if targetEnvironment(simulator)
            // Don't run this in a simulator on CI - it just crashes due to lack of Metal support
            // within earlier versions of macOS, and I didn't find an easy way to query the hosting
            // environment within compilation directives.
        #else
            func testmeshGeneration() throws {
                let positions: [Vector] = [
                    Vector(x: 0.5, y: -0.4330127, z: -0.4330127), // 0
                    Vector(x: -0.5, y: -0.4330127, z: -0.4330127), // 1
                    Vector(x: 0, y: 0.4330127, z: 0), // 2  (peak)
                    Vector(x: 0, y: -0.4330127, z: 0.4330127), // 3
                ]

                let back = Triangle(positions[0], positions[1], positions[2], material: ColorRepresentation.red)
                let bottom = Triangle(positions[0], positions[3], positions[1], material: ColorRepresentation.white)
                let left = Triangle(positions[0], positions[2], positions[3], material: ColorRepresentation.blue)
                let right = Triangle(positions[2], positions[1], positions[3], material: ColorRepresentation.green)
                let mesh = Mesh([back, bottom, left, right])

                // generating a MeshResource:
                let resource = try MeshResource.generate(from: mesh.descriptors)
                XCTAssertNotNil(resource)
                XCTAssertEqual(resource.contents.instances.count, 4)
                XCTAssertEqual(resource.contents.models.count, 4)
                XCTAssertEqual(resource.expectedMaterialCount, 1)
                print(resource.bounds)
                XCTAssertEqual(resource.bounds.min.x, -0.5, accuracy: 0.0001)
                XCTAssertEqual(resource.bounds.min.y, -0.4330127, accuracy: 0.0001)
                XCTAssertEqual(resource.bounds.min.z, -0.4330127, accuracy: 0.0001)
                XCTAssertEqual(resource.bounds.max.x, 0.5, accuracy: 0.0001)
                XCTAssertEqual(resource.bounds.max.y, 0.4330127, accuracy: 0.0001)
                XCTAssertEqual(resource.bounds.max.z, 0.4330127, accuracy: 0.0001)
                // print(" --- instances ---")
                // print(resource.contents.instances)
                /*
                 MeshInstanceCollection(table: [
                    "MeshModel-0": (extension in RealityFoundation):RealityKit.MeshResource.Instance(
                        id: "MeshModel-0",
                        model: "MeshModel",
                        transform: simd_float4x4([[1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 1.0]])),
                    "MeshModel[1]-0": (extension in RealityFoundation):RealityKit.MeshResource.Instance(
                        id: "MeshModel[1]-0",
                        model: "MeshModel[1]",
                        transform: simd_float4x4([[1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 1.0]])),
                    "MeshModel[3]-0": (extension in RealityFoundation):RealityKit.MeshResource.Instance(
                        id: "MeshModel[3]-0",
                        model: "MeshModel[3]",
                        transform: simd_float4x4([[1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 1.0]])),
                    "MeshModel[2]-0": (extension in RealityFoundation):RealityKit.MeshResource.Instance(
                        id: "MeshModel[2]-0",
                        model: "MeshModel[2]",
                        transform: simd_float4x4([[1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 1.0]]))
                 ])
                 */
            }
        
        func testUnifiedMeshGeneration() throws {
            let positions: [Vector] = [
                Vector(x: 0.5, y: -0.4330127, z: -0.4330127), // 0
                Vector(x: -0.5, y: -0.4330127, z: -0.4330127), // 1
                Vector(x: 0, y: 0.4330127, z: 0), // 2  (peak)
                Vector(x: 0, y: -0.4330127, z: 0.4330127), // 3
            ]

            let back = Triangle(positions[0], positions[1], positions[2], material: ColorRepresentation.red)
            let bottom = Triangle(positions[0], positions[3], positions[1], material: ColorRepresentation.white)
            let left = Triangle(positions[0], positions[2], positions[3], material: ColorRepresentation.blue)
            let right = Triangle(positions[2], positions[1], positions[3], material: ColorRepresentation.green)
            let mesh = Mesh([back, bottom, left, right])

            // generating a MeshResource:
            let resource = try MeshResource.generate(from: [mesh.unifiedDescriptor])
            XCTAssertNotNil(resource)
            XCTAssertEqual(resource.contents.instances.count, 1)
            XCTAssertEqual(resource.contents.models.count, 1)
            XCTAssertEqual(resource.expectedMaterialCount, 4)
            print(resource.bounds)
            XCTAssertEqual(resource.bounds.min.x, -0.5, accuracy: 0.0001)
            XCTAssertEqual(resource.bounds.min.y, -0.4330127, accuracy: 0.0001)
            XCTAssertEqual(resource.bounds.min.z, -0.4330127, accuracy: 0.0001)
            XCTAssertEqual(resource.bounds.max.x, 0.5, accuracy: 0.0001)
            XCTAssertEqual(resource.bounds.max.y, 0.4330127, accuracy: 0.0001)
            XCTAssertEqual(resource.bounds.max.z, 0.4330127, accuracy: 0.0001)
        }
        
/* example meshmodel dump:
 
"MeshModel[2]": (extension in RealityFoundation):RealityKit.MeshResource.Model(
         id: "MeshModel[2]",
         parts: RealityFoundation.MeshPartCollection(
            table: [
                "MeshPart": (extension in RealityFoundation):RealityKit.MeshResource.Part(
                    bufferDict: RealityFoundation.MeshBufferDictionary(
                        bufferTable: [
                            indexTriangles: RealityFoundation.MeshBufferDictionary.(unknown context at $2282367e0).BufferEntry<Swift.UInt16>(
                                id: indexTriangles,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.faceVarying,
                                elementType: RealityFoundation.MeshBuffers.ElementType.uInt16,
                                packed: false,
                                buffer: RealityFoundation.MeshBuffer<Swift.UInt16>(closure: RealityFoundation.MeshBuffer<Swift.UInt16>.Closures(getArray: (Function), getIndices: (Function), getData: (Function), chunk: (Function)),
                                elementType: RealityFoundation.MeshBuffers.ElementType.uInt16,
                                packed: false,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.faceVarying)
                            ),
                            vertexUV: RealityFoundation.MeshBufferDictionary.(unknown context at $2282367e0).BufferEntry<Swift.SIMD2<Swift.Float>>(
                                id: vertexUV,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.vertex,
                                elementType: RealityFoundation.MeshBuffers.ElementType.simd2Float,
                                packed: false,
                                buffer: RealityFoundation.MeshBuffer<Swift.SIMD2<Swift.Float>>(closure: RealityFoundation.MeshBuffer<Swift.SIMD2<Swift.Float>>.Closures(getArray: (Function), getIndices: (Function), getData: (Function), chunk: (Function)),
                                elementType: RealityFoundation.MeshBuffers.ElementType.simd2Float,
                                packed: false,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.vertex)
                            ),
                            vertexBitangent: RealityFoundation.MeshBufferDictionary.(unknown context at $2282367e0).BufferEntry<RealityFoundation.FloatVector3Packed>(
                                id: vertexBitangent,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.vertex,
                                elementType: RealityFoundation.MeshBuffers.ElementType.simd3Float,
                                packed: true,
                                buffer: RealityFoundation.MeshBuffer<RealityFoundation.FloatVector3Packed>(closure: RealityFoundation.MeshBuffer<RealityFoundation.FloatVector3Packed>.Closures(getArray: (Function), getIndices: (Function), getData: (Function), chunk: (Function)),
                                elementType: RealityFoundation.MeshBuffers.ElementType.simd3Float,
                                packed: true,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.vertex)
                            ),
                            vertexNormal: RealityFoundation.MeshBufferDictionary.(unknown context at $2282367e0).BufferEntry<RealityFoundation.FloatVector3Packed>(
                                id: vertexNormal,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.vertex,
                                elementType: RealityFoundation.MeshBuffers.ElementType.simd3Float,
                                packed: true,
                                buffer: RealityFoundation.MeshBuffer<RealityFoundation.FloatVector3Packed>(closure: RealityFoundation.MeshBuffer<RealityFoundation.FloatVector3Packed>.Closures(getArray: (Function), getIndices: (Function), getData: (Function), chunk: (Function)),
                                elementType: RealityFoundation.MeshBuffers.ElementType.simd3Float,
                                packed: true,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.vertex)
                            ),
                            vertexPosition: RealityFoundation.MeshBufferDictionary.(unknown context at $2282367e0).BufferEntry<RealityFoundation.FloatVector3Packed>(
                                id: vertexPosition,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.vertex,
                                elementType: RealityFoundation.MeshBuffers.ElementType.simd3Float,
                                packed: true,
                                buffer: RealityFoundation.MeshBuffer<RealityFoundation.FloatVector3Packed>(closure: RealityFoundation.MeshBuffer<RealityFoundation.FloatVector3Packed>.Closures(getArray: (Function), getIndices: (Function), getData: (Function), chunk: (Function)),
                                elementType: RealityFoundation.MeshBuffers.ElementType.simd3Float,
                                packed: true,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.vertex)
                            ),
                            vertexTangent: RealityFoundation.MeshBufferDictionary.(unknown context at $2282367e0).BufferEntry<RealityFoundation.FloatVector3Packed>(
                                id: vertexTangent,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.vertex,
                                elementType: RealityFoundation.MeshBuffers.ElementType.simd3Float,
                                packed: true,
                                buffer: RealityFoundation.MeshBuffer<RealityFoundation.FloatVector3Packed>(closure: RealityFoundation.MeshBuffer<RealityFoundation.FloatVector3Packed>.Closures(getArray: (Function), getIndices: (Function), getData: (Function), chunk: (Function)),
                                elementType: RealityFoundation.MeshBuffers.ElementType.simd3Float,
                                packed: true,
                                count: 3,
                                rate: RealityFoundation.MeshBuffers.Rate.vertex)
                            )
                        ]),
                        id: "MeshPart",
                        materialIndex: 0,
                        materialWasInvalid: false
                    )]
                )
            ),
         */
        #endif
    }
#endif
