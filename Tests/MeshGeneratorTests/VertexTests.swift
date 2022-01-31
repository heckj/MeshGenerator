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
        let v = Vertex(position: Vector(0, 0, 0))
        XCTAssertEqual(v.normal, .zero)
        XCTAssertEqual(v.tex, .zero)
    }

    func testVertexWith() throws {
        let v = Vertex(position: Vector(0, 0, 0))
        XCTAssertEqual(v.normal, .zero)
        XCTAssertEqual(v.tex, .zero)
        let newV = v.with(normal: Vector(0, 0, 1))
        XCTAssertEqual(newV.normal, Vector(0, 0, 1))
        XCTAssertEqual(newV.tex, .zero)
    }

    func testVertexWithNonNormal() throws {
        let v = Vertex(position: Vector(0, 0, 0))
        let newV = v.with(normal: Vector(0, 0, 10))
        XCTAssertEqual(newV.normal, Vector(0, 0, 1))
        XCTAssertEqual(newV.tex, .zero)
    }
    
}
