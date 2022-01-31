//
//  TriangleTests.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//

@testable import MeshGenerator
import XCTest

class TriangleTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPolygonVertexInitializer() throws {
        let v1 = Vertex(position: Vector(0,0,0))
        let v2 = Vertex(position: Vector(0,1,0))
        let v3 = Vertex(position: Vector(1,1,0))
        let triangle_up: [Vertex] = [v1,v3,v2]
        let triangle_down: [Vertex] = [v1,v2,v3]

        // no normal prior to adding
        XCTAssertEqual(v1.normal, .zero)
        
        let p1 = Triangle.init(triangle_up)
        XCTAssertNotNil(p1)
        XCTAssertEqual(p1?.plane.normal, Vector(0,0,1))
        // now it's got a pretty normal
        XCTAssertEqual(p1?.plane.normal, p1?.vertices[0].normal)
                       
        let p2 = Triangle.init(triangle_down)
        XCTAssertNotNil(p2)
        XCTAssertEqual(p2?.plane.normal, Vector(0,0,-1))
        // now it's got a pretty normal
        XCTAssertEqual(p2?.plane.normal, p2?.vertices[0].normal)
    }
}
