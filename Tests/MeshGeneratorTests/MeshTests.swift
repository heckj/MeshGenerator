//
//  MeshTests.swift
//
//
//  Created by Joseph Heck on 1/31/22.
//

@testable import MeshGenerator
import XCTest

class MeshTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMeshInitializer() throws {
        let m = Mesh([])
        XCTAssertTrue(m.isWatertight)
        XCTAssertEqual(m.materials.count, 0)
        XCTAssertEqual(m.polygons.count, 0)
        XCTAssertEqual(m.polygonsByMaterial.count, 0)
        XCTAssertEqual(m.uniqueEdges.count, 0)
        XCTAssertEqual(m.bounds, Bounds.empty)
        // @testable MeshGenerator tests
        XCTAssertTrue(m.isConvex)
    }

    func testSingleTriangleMesh() throws {
        let v1 = Vector(0, 0, 0)
        let v2 = Vector(0, 1, 0)
        let v3 = Vector(1, 1, 0)

        let polygon = Triangle([v1, v2, v3])
        let tri = Mesh([polygon!])

        XCTAssertFalse(tri.isWatertight)

        XCTAssertEqual(tri.materials.count, 1)
        XCTAssertEqual(tri.polygons.count, 1)
        XCTAssertEqual(tri.polygonsByMaterial.count, 1)
        XCTAssertEqual(tri.uniqueEdges.count, 3)
        XCTAssertEqual(tri.bounds,
                       Bounds(min: .zero, max: Vector(1, 1, 0)))
        // @testable MeshGenerator tests
        XCTAssertFalse(tri.isConvex)
    }
}
