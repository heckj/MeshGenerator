//
//  PlaneTests.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//

import MeshGenerator
import XCTest

class PlaneTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPlaneInitializer() throws {
        let xy = Plane(normal: Vector(0, 0, 1), pointOnPlane: Vector(0, 0, 0))
        XCTAssertNotNil(xy)
        XCTAssertEqual(Plane.xy, xy)
        if let xy = xy {
            XCTAssertTrue(xy.normal.isNormalized)
            XCTAssertEqual(xy.w, 0)
        }
    }

    func testPlaneFailingInitializer() throws {
        let invalid = Plane(normal: Vector(0, 0, 0), pointOnPlane: Vector(0, 0, 0))
        XCTAssertNil(invalid)
    }

    func testPlaneInitializerNonNormalNormal() throws {
        let xy = Plane(normal: Vector(0, 0, 10), pointOnPlane: Vector(0, 0, 0))
        XCTAssertNotNil(xy)
        XCTAssertEqual(Plane.xy, xy)
        if let xy = xy {
            XCTAssertTrue(xy.normal.isNormalized)
            XCTAssertEqual(xy.normal, Vector(0, 0, 1))
            XCTAssertEqual(xy.w, 0)
        }
    }

    func testPlaneInitializerPointCloud() throws {
        let xy = Plane(points: [
            Vector(0, 0, 0),
            Vector(1, 0, 0),
            Vector(1, 1, 0),
        ])
        XCTAssertNotNil(xy)
        XCTAssertEqual(Plane.xy, xy)
        XCTAssertEqual(xy?.normal, Vector(0, 0, 1))
    }

    func testPlaneInitializerPointCloudFlippedNormal() throws {
        let xy = Plane(points: [
            Vector(0, 0, 0),
            Vector(1, 1, 0),
            Vector(1, 0, 0),
        ])
        XCTAssertNotNil(xy)
        XCTAssertEqual(Plane.xy, xy?.inverted())
        XCTAssertEqual(xy?.normal, Vector(0, 0, -1))
    }

    func testPlaneInitializerPointCloudInvalid1() throws {
        let xy = Plane(points: [
            Vector(0, 0, 0),
            Vector(1, 1, 0),
        ])
        XCTAssertNil(xy)
    }

    func testPlaneInitializerPointCloudInvalid2() throws {
        // non-coplanar points
        let xy = Plane(points: [
            Vector(0, 0, 0),
            Vector(1, 0, 0),
            Vector(1, 1, 0),
            Vector(2, 0, 1),
        ])
        XCTAssertNil(xy)
    }

    func testPlaneInitializerPointCloudInvalid3() throws {
        // more than a quad, even if coplanar
        let xy = Plane(points: [
            Vector(0, 0, 0),
            Vector(1, 0, 0),
            Vector(1, 1, 0),
            Vector(2, 0, 0),
            Vector(2, 2, 0),
        ])
        XCTAssertNil(xy)
    }

    func testPlaneInitializerPointCloudInvalid4() throws {
        // quad, but concave
        let xy = Plane(points: [
            Vector(0, 0, 0),
            Vector(1, 0, 0),
            Vector(0, 1, 0),
            Vector(0.25, 0.5, 0),
        ])
        XCTAssertNil(xy)
    }

    func testContainsPoint() throws {
        XCTAssertTrue(Plane.xy.containsPoint(Vector(72, 54, 0)))
        XCTAssertFalse(Plane.xy.containsPoint(Vector(72, 54, 1)))
    }

    func testDistance() throws {
        XCTAssertEqual(Plane.xy.distance(from: Vector(72, 54, 1)), 1)
    }
}
