//
//  BoundsTests.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//

@testable import MeshGenerator
import XCTest

class BoundsTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBoundsInitializer() throws {
        let a = Vector(1, 0, 0)
        let b = Vector(3, 2, 1)
        let bounds = Bounds(a, b)
        XCTAssertFalse(bounds.hasNegativeVolume)
        XCTAssertFalse(bounds.isEmpty)
        XCTAssertEqual(bounds.size, Vector(2,2,1))
        XCTAssertEqual(bounds.center, Vector(2,1,0.5))
    }

    func testNegativeVolumeBoundsInitializer() throws {
        let a = Vector(1, 0, 0)
        let b = Vector(3, 2, 1)
        let bounds = Bounds(min: b, max: a)
        XCTAssertTrue(bounds.hasNegativeVolume)
        XCTAssertTrue(bounds.isEmpty)
        XCTAssertEqual(bounds.size, Vector.zero)
        XCTAssertEqual(bounds.center, Vector.zero)
    }

    func testBoundsContainsPoint() throws {
        let a = Vector(0, 0, 0)
        let b = Vector(3, 2, 1)
        let bounds = Bounds(a, b)
        XCTAssertFalse(bounds.containsPoint(Vector(-1,1,0)))
        XCTAssertTrue(bounds.containsPoint(Vector(1,1,0)))
    }

    // This test requires the @testable import,
    // as the bounds point cloud initializer is Internal
    func testBoundsPointsCloud() throws {
        let bounds = Bounds(points: [
            Vector(0,0,0),
            Vector(1,2,3),
            Vector(3,2,1),
            Vector(-1,-2,-3),
            Vector(-3,-2,-1)
        ])
        XCTAssertFalse(bounds.hasNegativeVolume)
        XCTAssertFalse(bounds.isEmpty)
        XCTAssertEqual(bounds.size, Vector(6,4,6))
        XCTAssertEqual(bounds.center, Vector(0,0,0))
    }
}
