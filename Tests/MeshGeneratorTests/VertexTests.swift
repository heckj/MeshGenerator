//
//  VertexTests.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//

@testable import MeshGenerator
import XCTest

class VertexTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVertexInitializer() throws {
        let v = Vertex(position: Vector(0,0,0))
        XCTAssertEqual(v.normal, .zero)
        XCTAssertEqual(v.tex, .zero)
    }

    func testVertexWith() throws {
        let v = Vertex(position: Vector(0,0,0))
        XCTAssertEqual(v.normal, .zero)
        XCTAssertEqual(v.tex, .zero)
        let newV = v.with(normal: Vector(0,0,1))
        XCTAssertEqual(newV.normal, Vector(0,0,1))
        XCTAssertEqual(newV.tex, .zero)
    }

    func testVertexWithNonNormal() throws {
        let v = Vertex(position: Vector(0,0,0))
        let newV = v.with(normal: Vector(0,0,10))
        XCTAssertEqual(newV.normal, Vector(0,0,1))
        XCTAssertEqual(newV.tex, .zero)
    }

    func testVertexPointSet1() throws {
        let v1 = Vertex(position: Vector(0,0,0))
        let v2 = Vertex(position: Vector(0,1,0))
        let v3 = Vertex(position: Vector(1,1,0))
        let v4 = Vertex(position: Vector(1,0,0))
        let v5 = Vertex(position: Vector(0,0,1))
        XCTAssertFalse(Vertex.verticesAreDegenerate([v1,v2,v3,v4,v5]))
        XCTAssertTrue(Vertex.verticesAreConvex([v1,v2,v3,v4]))
        XCTAssertFalse(Vertex.verticesAreCoplanar([v1,v2,v3,v4,v5]))
        XCTAssertTrue(Vertex.verticesAreCoplanar([v1,v2,v3,v4]))
    }
    
    func testDegenerateVertexList() throws {
        let v1 = Vertex(position: Vector(0,0,0))
        let v2 = Vertex(position: Vector(0,1,0))
        let v3 = Vertex(position: Vector(1,1,0))
        let v4 = Vertex(position: Vector(1,0,0))
        let quickset_bad: [Vertex] = [v1,v3,v2,v4]
        let quickset_good: [Vertex] = [v1,v2,v3,v4]
        XCTAssertTrue(Vertex.verticesAreDegenerate(quickset_bad))
        XCTAssertTrue(Vertex.pointsAreSelfIntersecting(quickset_bad.map({ $0.position })))
        
        XCTAssertFalse(Vertex.verticesAreDegenerate(quickset_good))
        XCTAssertFalse(Vertex.pointsAreSelfIntersecting(quickset_good.map({ $0.position })))
        
        XCTAssertTrue(Vertex.verticesAreCoplanar(quickset_bad))
        XCTAssertTrue(Vertex.verticesAreCoplanar(quickset_good))

        XCTAssertTrue(Vertex.pointsAreCoplanar(quickset_bad.map { $0.position }))
        XCTAssertTrue(Vertex.pointsAreCoplanar(quickset_good.map { $0.position }))

    }
}
