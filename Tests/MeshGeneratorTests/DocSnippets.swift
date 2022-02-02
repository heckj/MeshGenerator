//
//  DocSnippets.swift
//  
//
//  Created by Joseph Heck on 2/2/22.
//

import MeshGenerator
import XCTest
import SceneKit

class DocSnippetTests: XCTestCase {
    
    func testMeshOverview1() throws {
        let positions: [Vector] = [
            Vector(x: 0.05, y: 0, z: 0), // 0
            Vector(x: -0.05, y: 0, z: 0), // 1
            Vector(x: 0, y: 1, z: 0), // 2
            Vector(x: 0, y: 0, z: 0.5), // 3
        ]
        
        let back = Triangle(positions[0], positions[1], positions[2])
        let bottom = Triangle(positions[0], positions[3], positions[1])
        let left = Triangle(positions[0], positions[2], positions[3])
        let right = Triangle(positions[2], positions[1], positions[3])
        let mesh = Mesh([back, bottom, left, right])
        // Geometry from the mesh:
        let geo = SCNGeometry(mesh)

        XCTAssertNotNil(geo)
        
    }

    func testMeshOverview2() throws {
        let positions: [Vector] = [
            Vector(x: 0.05, y: 0, z: 0), // 0
            Vector(x: -0.05, y: 0, z: 0), // 1
            Vector(x: 0, y: 1, z: 0), // 2
            Vector(x: 0, y: 0, z: 0.5), // 3
        ]
        
        let back = Triangle(positions[0], positions[1], positions[2])
        let bottom = Triangle(positions[0], positions[3], positions[1])
        let left = Triangle(positions[0], positions[2], positions[3])
        let right = Triangle(positions[2], positions[1], positions[3])
        let mesh = Mesh([back, bottom, left, right])
        // Bounding Box geometry from the mesh:
         let geo = SCNGeometry(mesh.bounds)
        
        XCTAssertNotNil(geo)
        
    }

    func testMeshOverview3() throws {
        let positions: [Vector] = [
            Vector(x: 0.05, y: 0, z: 0), // 0
            Vector(x: -0.05, y: 0, z: 0), // 1
            Vector(x: 0, y: 1, z: 0), // 2
            Vector(x: 0, y: 0, z: 0.5), // 3
        ]
        
        let back = Triangle(positions[0], positions[1], positions[2])
        let bottom = Triangle(positions[0], positions[3], positions[1])
        let left = Triangle(positions[0], positions[2], positions[3])
        let right = Triangle(positions[2], positions[1], positions[3])
        let mesh = Mesh([back, bottom, left, right])

        // Wireframe geometry from the mesh:
        let geo = SCNGeometry(wireframe: mesh)
        
        XCTAssertNotNil(geo)
        
    }

}
