//
//  VectorTests.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//

import MeshGenerator
import XCTest

class VectorTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: Vector length and normalization

    func testAxisAlignedLength() throws {
        let vector = Vector(1, 0, 0)
        XCTAssertEqual(vector.length, 1)
    }

    func testAngledLength() throws {
        let vector = Vector(2, 5, 3)
        let length = (2.0 * 2.0 + 5.0 * 5.0 + 3.0 * 3.0).squareRoot()
        XCTAssertEqual(vector.length, length)
    }

    func testNormalized() throws {
        let vector = Vector(2, 5, 3)
        XCTAssertNotEqual(vector.length, 1)
        XCTAssertEqual(vector.normalized().length, 1)
    }

    func testNormalizedZero() throws {
        let vector = Vector.zero
        XCTAssertEqual(vector.normalized().length, 0)
    }

    func testVectorMinMax() throws {
        let a = Vector(1, 2, 3)
        let b = Vector(-1, -2, -3)
        XCTAssertEqual(a.min(b), Vector(-1, -2, -3))
        XCTAssertEqual(a.max(b), Vector(1, 2, 3))
        XCTAssertEqual(b.min(a), Vector(-1, -2, -3))
        XCTAssertEqual(b.max(a), Vector(1, 2, 3))
    }

    func testVectorComponentMinMax() throws {
        let a = Vector(1, 2, 3)
        XCTAssertEqual(a.min(), 1)
        XCTAssertEqual(a.max(), 3)
    }

    func testVectorDistance() throws {
        let a = Vector(0, 0, 3)
        let b = Vector.zero
        XCTAssertEqual(a.distance(from: b), 3)
    }
}
