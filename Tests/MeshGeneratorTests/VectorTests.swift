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

    func testAxisAlignedLength() {
        let vector = Vector(1, 0, 0)
        XCTAssertEqual(vector.length, 1)
    }

    func testAngledLength() {
        let vector = Vector(2, 5, 3)
        let length = (2.0 * 2.0 + 5.0 * 5.0 + 3.0 * 3.0).squareRoot()
        XCTAssertEqual(vector.length, length)
    }

    func testNormalized() {
        let vector = Vector(2, 5, 3)
        XCTAssertNotEqual(vector.length, 1)
        XCTAssertEqual(vector.normalized().length, 1)
    }
}
