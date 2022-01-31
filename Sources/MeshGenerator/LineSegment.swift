//
//  LineSegment.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//  Copyright © 2022 Joseph Heck. All rights reserved.
//
//  Portions of this code Created by Nick Lockwood on 03/07/2018.
//  Copyright © 2018 Nick Lockwood. All rights reserved.
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/Euclid
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/// A struct that represents a finite-length line segment in 3D space.
///
/// A line sgement is defined by a `start` point and an `end` point.
public struct LineSegment: Hashable {
    public let start, end: Vector

    /// Creates a line segment from a start and end point.
    /// - Parameters:
    ///   - start: The start of the line segment.
    ///   - end: The end of the line segment.
    public init?(_ start: Vector, _ end: Vector) {
        guard start != end else {
            return nil
        }
        self.start = start
        self.end = end
    }
}

internal extension LineSegment {
    init(unchecked start: Vector, _ end: Vector) {
        assert(start != end)
        self.start = start
        self.end = end
    }

    init(normalized start: Vector, _ end: Vector) {
        if start < end {
            self.init(unchecked: start, end)
        } else {
            self.init(unchecked: end, start)
        }
    }
}

extension LineSegment: Comparable {
    /// Returns a Boolean value that compares two line segments to provide a stable sort order.
    /// - Parameters:
    ///   - lhs: The first line segment to compare.
    ///   - rhs: The second line segment to compare.
    public static func < (lhs: LineSegment, rhs: LineSegment) -> Bool {
        if lhs.start == rhs.start {
            return lhs.end < rhs.end
        }
        return lhs.start < rhs.start
    }
}

public extension LineSegment {
    /// Calculates the shortest distance between two lines within 3D space.
    ///
    /// If the lines are intersecting, the points returned will be identical.
    /// For more information about the technique used, see
    /// [The shortest line between two lines in 3D](http://paulbourke.net/geometry/pointlineplane/) by [Paul Bourke](http://paulbourke.net/geometry/)
    ///
    /// - Parameters:
    ///   - p1: The starting location of the first line segment.
    ///   - p2: The ending location of the first line segment.
    ///   - p3: The starting location of the second line segment.
    ///   - p4: The ending location of the second line segment.
    /// - Returns: A tuple of vectors that represents the endpoints of the shortest line, or nil if the lines are coincident or parallel.
    static func shortestLineBetween(
        _ p1: Vector,
        _ p2: Vector,
        _ p3: Vector,
        _ p4: Vector
    ) -> (Vector, Vector)? {
        // Shortest line segment between two lines
        // http://paulbourke.net/geometry/pointlineplane/
        let p21 = p2 - p1
        assert(p21.length > 0)
        let p43 = p4 - p3
        assert(p43.length > 0)
        let p13 = p1 - p3

        let d1343 = p13.dot(p43)
        let d4321 = p43.dot(p21)
        let d1321 = p13.dot(p21)
        let d4343 = p43.dot(p43)
        let d2121 = p21.dot(p21)

        let denominator = d2121 * d4343 - d4321 * d4321
        guard abs(denominator) > Vector.epsilon else {
            // Lines are coincident
            return nil
        }

        let numerator = d1343 * d4321 - d1321 * d4343
        let mua = numerator / denominator
        let mub = (d1343 + d4321 * mua) / d4343

        return (p1 + p21 * mua, p3 + p43 * mub)
    }

    /// Returns a vector that represents the point on the infinite line you define that results in the shortest length.
    /// - Parameters:
    ///   - point: The point to calculate from.
    ///   - lineOrigin: A point on an infinite line
    ///   - lineDirection: A normalized vector describing the direction of the line.
    /// - Returns: A vector that represents the point nearest to the point you provide.
    static func vectorFromPointToLine(
        point: Vector,
        lineOrigin: Vector,
        lineDirection: Vector
    ) -> Vector {
        // See "Vector formulation" at https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
        assert(lineDirection.isNormalized)
        let d = point - lineOrigin
        return lineDirection * d.dot(lineDirection) - d
    }

    /// Returns a vector that indicates if the points that make up two line segments intersect.
    /// - Parameters:
    ///   - p0: The starting location of the first line segment.
    ///   - p1: The ending location of the first line segment.
    ///   - p2: The starting location of the second line segment.
    ///   - p3: The ending location of the second line segment.
    /// - Returns: A vector that describes the point of intersection, or `nil` if there is no intersection.
    static func lineIntersection(
        _ p0: Vector,
        _ p1: Vector,
        _ p2: Vector,
        _ p3: Vector
    ) -> Vector? {
        let ls1 = (p0 - p1).normalized()
        let ls2 = (p2 - p3).normalized()
        if ls1.isApproximatelyEqual(to: ls2) || ls1.isApproximatelyEqual(to: -ls2) {
            // lines are parallel, so shortestLineBetween
            // won't work - denominator goes to 0.
            if Bounds(p0, p1).containsPoint(p2) {
                return p2
            } else if Bounds(p0, p1).containsPoint(p3) {
                return p3
            } else {
                return nil
            }
        }
        guard let (p0, p1) = shortestLineBetween(p0, p1, p2, p3) else {
            return nil
        }
        return p0.isApproximatelyEqual(to: p1) ? p0 : nil
    }

    /// The direction of the line segment as a normalized vector.
    var direction: Vector {
        (end - start).normalized()
    }

    /// The length of the line segment.
    var length: Double {
        (end - start).length
    }

    /// Returns a Boolean value that indicates whether the point is on the line segment.
    /// - Parameter p: The point to compare.
    func containsPoint(_ p: Vector) -> Bool {
        let v = LineSegment.vectorFromPointToLine(point: p, lineOrigin: start, lineDirection: direction)
        guard v.length < Vector.epsilon else {
            return false
        }
        return Bounds(start, end).containsPoint(p)
    }

    /// Returns a point that indicates the intersection of the line segement you provide.
    /// - Parameter segment: The line segment to compare.
    /// - Returns: The point of intersection, or `nil` if the segments don't intersect.
    func intersection(with segment: LineSegment) -> Vector? {
        LineSegment.lineIntersection(start, end, segment.start, segment.end)
    }

    /// Returns a Boolean value that indicates whether line segement intersects.
    /// - Parameter segment: The line segment to compare.
    func intersects(_ segment: LineSegment) -> Bool {
        intersection(with: segment) != nil
    }
}
