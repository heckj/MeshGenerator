//
//  LineSegmentTests.swift
//
//
//  Created by Joseph Heck on 1/30/22.
//

@testable import MeshGenerator
import XCTest

class LineSegmentTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLineSegmentInitializer() throws {
        let a = Vector(1, 0, 0)
        let b = Vector(3, 0, 0)
        let segment = LineSegment(a, b)
        XCTAssertNotNil(segment)
        XCTAssertEqual(segment?.direction, Vector(1, 0, 0))
        XCTAssertEqual(segment?.length, 2)
        XCTAssertEqual(segment?.length, b.distance(from: a))
    }

    func testLineSegmentFailingInitializer() throws {
        let a = Vector(1, 0, 0)
        let segment = LineSegment(a, a)
        XCTAssertNil(segment)
    }

    func testLineSegmentContainsPoint() throws {
        let a = Vector(1, 0, 0)
        let b = Vector(5, 0, 0)
        let segment = LineSegment(a, b)!
        XCTAssertTrue(segment.containsPoint(Vector(2, 0, 0)))
        XCTAssertFalse(segment.containsPoint(Vector(0, 0, 0)))
        XCTAssertTrue(segment.containsPoint(Vector(1, 0, 0)))
        XCTAssertTrue(segment.containsPoint(Vector(5, 0, 0)))
        XCTAssertFalse(segment.containsPoint(Vector(2, 0, 0.00000001)))
    }

    func testShortestLineBetweenParallelLines() throws {
        let tuple = LineSegment.shortestLineBetween(
            Vector(0, 0, 0), Vector(2, 0, 0), Vector(0, 1, 1), Vector(2, 1, 1)
        )
        // parallel lines return nil
        XCTAssertNil(tuple)
    }

    func testLineIntersectionParallelLines() throws {
        let result = LineSegment.lineIntersection(
            Vector(0, 0, 0), Vector(2, 0, 0), Vector(0, 1, 1), Vector(2, 1, 1)
        )
        // parallel lines return nil
        XCTAssertNil(result)
    }

    func testLineIntersectionCoincidentLines() throws {
        let result = LineSegment.lineIntersection(
            Vector(0, 0, 0), Vector(2, 0, 0), Vector(1, 0, 0), Vector(2, 0, 0)
        )
        XCTAssertEqual(result, Vector(1, 0, 0))
    }

    func testShortestLineBetween1() throws {
        let tuple = LineSegment.shortestLineBetween(
            Vector(0, 0, 0), Vector(2, 0, 0), Vector(0, 0, 0), Vector(2, 1, 0)
        )

        XCTAssertNotNil(tuple)
        XCTAssertEqual(tuple?.0, Vector(0, 0, 0))
        XCTAssertEqual(tuple?.1, Vector(0, 0, 0))
    }

    func testShortestLineBetween2() throws {
        let tuple = LineSegment.shortestLineBetween(
            Vector(0, 0, 0), Vector(2, 0, 0), Vector(0, 1, 0), Vector(2, 2, 0)
        )

        XCTAssertNotNil(tuple)
        XCTAssertEqual(tuple?.0, Vector(-2, 0, 0))
        XCTAssertEqual(tuple?.1, Vector(-2, 0, 0))
    }

    func testShortestLineBetween3() throws {
        let tuple = LineSegment.shortestLineBetween(
            Vector(0, 0, 0), Vector(2, 0, 0), Vector(0, -1, 0), Vector(0, 2, 0)
        )

        XCTAssertNotNil(tuple)
        XCTAssertEqual(tuple?.0, Vector(0, 0, 0))
        XCTAssertEqual(tuple?.1, Vector(0, 0, 0))
    }

    func testShortestLineBetween4() throws {
        let tuple = LineSegment.shortestLineBetween(
            Vector(0, 0, 0), Vector(2, 0, 0), Vector(0, -1, 1), Vector(0, 2, 1)
        )

        XCTAssertNotNil(tuple)
        XCTAssertEqual(tuple?.0, Vector(0, 0, 0))
        XCTAssertEqual(tuple?.1, Vector(0, 0, 1))
    }

    func testVectorFromPointToLine1() throws {
        let v = LineSegment.vectorFromPointToLine(point: Vector(0, 0, 0), lineOrigin: Vector(2, 0, 0), lineDirection: Vector(0, 1, 0))

        XCTAssertEqual(v, Vector(2, 0, 0))
    }

    func testVectorFromPointToLine2() throws {
        let v = LineSegment.vectorFromPointToLine(point: Vector(0, 0, 0), lineOrigin: Vector(2, 0, 0), lineDirection: Vector(1, 1, 0).normalized())

        XCTAssertTrue(v.isApproximatelyEqual(to: Vector(1, -1, 0)))
    }

    func testParallelOverlappingLineSegmentIntersection() throws {
        let a = Vector(1, 0, 0)
        let b = Vector(5, 0, 0)
        let segment1 = LineSegment(a, b)!
        let segment2 = LineSegment(Vector(3, 0, 0), Vector(5, 0, 0))!
        // NOTE: parallel and slightly overlapping line segments
        // DO NOT register as intersecting.
        let intersectionVector = segment1.intersection(with: segment2)
        XCTAssertEqual(intersectionVector, Vector(3, 0, 0))
        XCTAssertTrue(segment1.intersects(segment2))
    }

    func testTouchingLineSegmentIntersection() throws {
        let a = Vector(1, 0, 0)
        let b = Vector(5, 0, 0)
        let segment1 = LineSegment(a, b)!
        let segment2 = LineSegment(Vector(1, 0, 0), Vector(1, 0, 5))!
        // NOTE: Line segments with a single point in common
        // DO register as intersecting.
        let intersectionVector = segment1.intersection(with: segment2)
        XCTAssertNotNil(intersectionVector)
        XCTAssertEqual(intersectionVector, Vector(1, 0, 0))
        XCTAssertTrue(segment1.intersects(segment2))
    }

    func testLineSegmentIntersection() throws {
        let a = Vector(1, 0, 0)
        let b = Vector(5, 0, 0)
        let segment1 = LineSegment(a, b)!
        let segment2 = LineSegment(Vector(3, 1, 0), Vector(3, -1, 0))!

        let intersectionVector = segment1.intersection(with: segment2)
        XCTAssertNotNil(intersectionVector)
        XCTAssertEqual(intersectionVector, Vector(3, 0, 0))
        XCTAssertTrue(segment1.intersects(segment2))
    }
}
