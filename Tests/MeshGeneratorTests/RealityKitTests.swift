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
    }
}
#endif
