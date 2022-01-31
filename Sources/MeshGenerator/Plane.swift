//
//  Plane.swift
//
//
//  Created by Nick Lockwood on 03/07/2018.
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

/// A struct that represents an infinite 2D plane in 3D space.
///
/// A plane is defined by a ``Plane/normal``, a surface normal ``Vector``, and ``Plane/w``,  the distance from the the center of the plane from the world origin coordinates.
public struct Plane: Hashable {
    /// The surface normal vector.
    ///
    /// A surface normal vector is perpendicular to the plane.
    public let normal: Vector
    /// The distance from the center of the plane to the world origin coordinates.
    public let w: Double

    /// Creates a plane from a surface normal and a distance from the world origin
    init?(normal: Vector, w: Double) {
        let length = normal.length
        guard length.isFinite, length > Vector.epsilon else {
            return nil
        }
        self.init(unchecked: normal / length, w: w)
    }
}

extension Plane: Comparable {
    /// Provides a stable sort order for Planes
    public static func < (lhs: Plane, rhs: Plane) -> Bool {
        if lhs.normal == rhs.normal {
            return lhs.w < rhs.w
        }
        return lhs.normal < rhs.normal
    }
}

public extension Plane {
    /// A plane at the origin, aligned with the Y and Z coordinates.
    static let yz = Plane(unchecked: Vector(1, 0, 0), w: 0)
    /// A plane at the origin, aligned with the X and Z coordinates.
    static let xz = Plane(unchecked: Vector(0, 1, 0), w: 0)
    /// A plane at the origin, aligned with the X and Y coordinates.
    static let xy = Plane(unchecked: Vector(0, 0, 1), w: 0)

    /// Creates a plane from a point and surface normal
    init?(normal: Vector, pointOnPlane: Vector) {
        let length = normal.length
        guard length.isFinite, length > Vector.epsilon else {
            return nil
        }
        self.init(unchecked: normal.normalized(), pointOnPlane: pointOnPlane)
    }

    /// Creates a plane from a set of coplanar points describing a polygon.
    ///
    /// The polygon must be convex, and either a trianle or quad (3 or 4 points).
    /// The direction of the plane normal is based on the assumption that the points are wind in an anti-clockwise direction.
    init?(points: [Vector]) {
        guard !points.isEmpty,
              points.count == 3
        else {
            return nil
        }
        self.init(unchecked: points)
        // Check all points lie on this plane
        if points.contains(where: { !containsPoint($0) }) {
            return nil
        }
    }

    /// Returns the flip-side of the plane.
    func inverted() -> Plane {
        Plane(unchecked: -normal, w: -w)
    }

    /// Returns a Boolean value that indicates whether a point is on the plane.
    func containsPoint(_ p: Vector) -> Bool {
        abs(distance(from: p)) < Vector.epsilon
    }

    /// Returns the distance of the point from a plane.
    ///
    /// A positive value is returned if the point lies in front of the plane.
    /// A negative value is returned if the point lies behind the plane.
    func distance(from p: Vector) -> Double {
        normal.dot(p) - w
    }
}

internal extension Plane {
    init(unchecked normal: Vector, w: Double) {
        assert(normal.isNormalized)
        self.normal = normal
        self.w = w
    }

    init(unchecked normal: Vector, pointOnPlane: Vector) {
        self.init(unchecked: normal, w: normal.dot(pointOnPlane))
    }

    init(unchecked points: [Vector]) {
        let normal = Triangle.faceNormalForConvexPoints(points)
        self.init(unchecked: normal, pointOnPlane: points[0])
    }

    // Approximate equality
    func isEqual(to other: Plane, withPrecision p: Double = Vector.epsilon) -> Bool {
        abs(w - other.w) < p && normal.isApproximatelyEqual(to: other.normal, withPrecision: p)
    }
}
