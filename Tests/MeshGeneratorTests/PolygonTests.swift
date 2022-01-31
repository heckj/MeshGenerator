//
//  PolygonTests.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//

@testable import MeshGenerator
import XCTest

class PolygonTests: XCTestCase {
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
//        let v4 = Vertex(position: Vector(1,0,0))
        let traingle_up: [Vertex] = [v1,v3,v2]
        let triangle_down: [Vertex] = [v1,v2,v3]

        // no normal prior to adding
        XCTAssertEqual(v1.normal, .zero)
        
        let p1 = Polygon.init(traingle_up)
        XCTAssertNotNil(p1)
        XCTAssertEqual(p1?.plane.normal, Vector(0,0,1))
        // now it's got a pretty normal
        XCTAssertEqual(p1?.plane.normal, p1?.vertices[0].normal)
                       
        let p2 = Polygon.init(triangle_down)
        XCTAssertNotNil(p2)
        XCTAssertEqual(p2?.plane.normal, Vector(0,0,-1))
        // now it's got a pretty normal
        XCTAssertEqual(p2?.plane.normal, p2?.vertices[0].normal)
    }

//    func testPolygonVertexInitializerWithNormals() throws {
//        let v1 = Vertex(position: Vector(0,0,0), normal: Vector(1,1,0))
//        let v2 = Vertex(position: Vector(0,1,0), normal: Vector(1,1,0))
//        let v3 = Vertex(position: Vector(1,1,0), normal: Vector(1,1,0))
//        let v4 = Vertex(position: Vector(1,0,0), normal: Vector(1,1,0))
//
//        let quickset_good: [Vertex] = [v1,v2,v3,v4]
//
//        let p1 = Polygon.init(quickset_good)
//        XCTAssertNotNil(p1)
//        // The calculated plane normal should be straight up
//        XCTAssertEqual(p1?.plane.normal, Vector(0,0,1))
//        // but the provided normals should persist
//        XCTAssertNotEqual(p1?.plane.normal, p1?.vertices[0].normal)
//    }

//    func testPolygonVectorInitializer() throws {
//        let v1 = Vector(0,0,0)
//        let v2 = Vector(0,1,0)
//        let v3 = Vector(1,1,0)
//        let v4 = Vector(1,0,0)
//        let quickset_bad: [Vector] = [v1,v3,v2,v4]
//        let quickset_good: [Vector] = [v1,v2,v3,v4]
//
//        let p1 = Polygon.init(quickset_good)
//        XCTAssertNotNil(p1)
//        XCTAssertEqual(p1?.plane.normal, Vector(0,0,1))
//
//        XCTAssertEqual(p1?.plane.normal, p1?.vertices[0].normal)
//        let p2 = Polygon.init(quickset_bad)
//        XCTAssertNil(p2)
//    }

//    func testFaceNormalForConvexPoints() throws {
//        let v1 = Vector(0,0,0)
//        let v2 = Vector(0,1,0)
//        let v3 = Vector(1,1,0)
//        let v4 = Vector(1,0,0)
//
//        // 3 pt scenarios
//        XCTAssertEqual(Polygon.faceNormalForConvexPoints([v1,v2,v3]), Vector(0,0,-1))
//        XCTAssertEqual(Polygon.faceNormalForConvexPoints([v3,v2,v1]), Vector(0,0,1))
//        // 4 pt scenarios
//        XCTAssertEqual(Polygon.faceNormalForConvexPoints([v1,v2,v3,v4]), Vector(0,0,-1))
//        XCTAssertEqual(Polygon.faceNormalForConvexPoints([v4,v3,v2,v1]), Vector(0,0,1))
//    }

}
