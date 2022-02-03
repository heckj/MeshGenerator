//
//  ExportContentTests.swift
//
//
//  Created by Joseph Heck on 2/2/22.
//

import MeshGenerator
import XCTest
import SceneKit

class ExportContentTests: XCTestCase {

    func testExportTetrahedronSceneKit() throws {
        let positions: [Vector] = [
            Vector(x: 0.5, y: -0.4330127, z: -0.4330127),  // 0
            Vector(x: -0.5, y: -0.4330127, z: -0.4330127), // 1
            Vector(x: 0, y: 0.4330127, z: 0),              // 2  (peak)
            Vector(x: 0, y: -0.4330127, z: 0.4330127),     // 3
        ]

        let back = Triangle(positions[0], positions[1], positions[2], material: ColorRepresentation.red)
        let bottom = Triangle(positions[0], positions[3], positions[1], material: ColorRepresentation.white)
        let left = Triangle(positions[0], positions[2], positions[3], material: ColorRepresentation.blue)
        let right = Triangle(positions[2], positions[1], positions[3], material: ColorRepresentation.green)
        let mesh = Mesh([back, bottom, left, right])

        // Geometry from the mesh:
        let geo = SCNGeometry(mesh)
        geo.materials = [SCNMaterial(ColorRepresentation.red)]
        let scene = SCNScene()
        scene.rootNode.addChildNode(SCNNode(geometry: geo))

        let path = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)[0]
                                                 .appendingPathComponent("tetrahedron.usdz")

        #if os(watchOS)
        #else
            scene.write(to: path, options: nil, delegate: nil, progressHandler: nil)
        #endif
        XCTAssertNotNil(geo)

    }

    func testExportTetrahedronColored() throws {
        let positions: [Vector] = [
            Vector(x: 0.5, y: -0.4330127, z: -0.4330127),  // 0
            Vector(x: -0.5, y: -0.4330127, z: -0.4330127), // 1
            Vector(x: 0, y: 0.4330127, z: 0),              // 2  (peak)
            Vector(x: 0, y: -0.4330127, z: 0.4330127),     // 3
        ]

        let back = Triangle(positions[0], positions[1], positions[2], material: ColorRepresentation.red)
        let bottom = Triangle(positions[0], positions[3], positions[1], material: ColorRepresentation.white)
        let left = Triangle(positions[0], positions[2], positions[3], material: ColorRepresentation.blue)
        let right = Triangle(positions[2], positions[1], positions[3], material: ColorRepresentation.green)
        let mesh = Mesh([back, bottom, left, right])
        // Geometry from the mesh:
        let geo = SCNGeometry(mesh)

        let scene = SCNScene()
        let node = SCNNode(geometry: geo)

        scene.rootNode.addChildNode(node)

        let path = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)[0]
                                                 .appendingPathComponent("tetrahedronColored.usdz")
        #if os(watchOS)
        #else
        scene.write(to: path, options: nil, delegate: nil, progressHandler: nil)
        #endif
        XCTAssertNotNil(geo)

    }

}
