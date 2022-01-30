//
//  Polygon.swift
//
//
//  Created by Joseph Heck on 1/29/22.
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

import Foundation

public struct Polygon {
    typealias Material = AnyHashable
    /// The class for the storage of the relevant values and objects that make up the Polygon.
    private var storage: Storage
    
    /// The collection of vertices that make up the polygon.
    public var vertices: [Vertex] { storage.vertices }
//    /// The plane that describes the polygon's face.
//    var plane: Plane { storage.plane }
    /// The bounds of the polygon.
    public var bounds: Bounds { Bounds(points: vertices.map { $0.position }) }
    
    /// Creates a polygon from a set of vertices.
    ///
    /// A polygon can be convex or concave, but vertices must be coplanar and non-degenerate.
    /// Vertices are assumed to be in anti-clockwise order for the purpose of deriving the plane.
    init?(_ vertices: [Vertex], material: Material? = nil) {
        let positions = vertices.map { $0.position }
        let isConvex = Vertex.pointsAreConvex(positions)
        guard positions.count > 2
                //, !pointsAreSelfIntersecting(positions),
              // Note: Plane init includes check for degeneracy
              //let plane = Plane(points: positions, convex: isConvex)
        else {
            return nil
        }
        self.init(
            unchecked: vertices,
            //plane: plane,
            isConvex: isConvex,
            //sanitizeNormals: true,
            material: material
        )
    }

    /// Creates a polygon from a set of vertex positions.
    ///
    /// Vertex normals will be set to match face normal.
    init?(_ vertices: [Vector], material: Material? = nil) {
        self.init(vertices.map { Vertex(position: $0) }, material: material)
    }
    
    /// Returns a vector that is the face normal direction for the list of points you provide.
    ///
    /// The points are assumed to be ordered in a counter-clockwise direction.
    /// The points are not verified to be coplanar or non-degenerate, and aren't  required to form a convex polygon.
    /// 
    /// - Parameters:
    ///   - points: The points making up the face of a polygon.
    ///   - convex: A Boolean value that indicates the points provided are convex.
    public static func faceNormalForPolygonPoints(_ points: [Vector], convex: Bool?) -> Vector {
        let count = points.count
        let unitZ = Vector(0, 0, 1)
        switch count {
        case 0, 1:
            return unitZ
        case 2:
            let ab = points[1] - points[0]
            let normal = ab.cross(unitZ).cross(ab)
            let length = normal.length
            guard length > 0 else {
                // Points lie along z axis
                return Vector(1, 0, 0)
            }
            return normal / length
        default:
            func faceNormalForConvexPoints(_ points: [Vector]) -> Vector {
                var b = points[0]
                var ab = b - points.last!
                var bestLengthSquared = 0.0
                var best: Vector?
                for c in points {
                    let bc = c - b
                    let normal = ab.cross(bc)
                    let lengthSquared = normal.lengthSquared
                    if lengthSquared > bestLengthSquared {
                        bestLengthSquared = lengthSquared
                        best = normal / lengthSquared.squareRoot()
                    }
                    b = c
                    ab = bc
                }
                return best ?? Vector(0, 0, 1)
            }
            let normal = faceNormalForConvexPoints(points)
            let convex = convex ?? Vertex.pointsAreConvex(points)
            if !convex {
                let flatteningPlane = FlatteningPlane(normal: normal)
                let flattenedPoints = points.map { flatteningPlane.flattenPoint($0) }
                let flattenedNormal = faceNormalForConvexPoints(flattenedPoints)
                let isClockwise = flattenedPointsAreClockwise(flattenedPoints)
                if (flattenedNormal.z > 0) == isClockwise {
                    return -normal
                }
            }
            return normal
        }
    }
}

internal extension Polygon {
    /// Creates a polygon from vertices with no validation.
    ///
    /// Vertices may be convex or concave, but are assumed to describe a non-degenerate polygon.
    /// Vertices are assumed to be in counter-clockwise order for the purpose of deriving the plane.
    ///
    /// - Parameters:
    ///   - vertices: The list of vertices, in counter-clockwise order, that describe the polygon.
    ///   - isConvex: <#isConvex description#>
    ///   - sanitizeNormals: Whether to iterate over and sanitize the normals for each of the vertices provided.
    ///   - material: The material for the polygone.
    init(
        unchecked vertices: [Vertex],
        isConvex: Bool?,
        sanitizeNormals: Bool = false,
        material: Material?
    ) {
        assert(!Vertex.verticesAreDegenerate(vertices))
        let points = vertices.map { $0.position }
        assert(isConvex == nil || Vertex.pointsAreConvex(points) == isConvex)
        assert(sanitizeNormals || vertices.allSatisfy { $0.normal != .zero })
        let plane = Plane(unchecked: points, convex: isConvex)
        let isConvex = isConvex ?? Vertex.pointsAreConvex(points)
        self.storage = Storage(
            vertices: vertices.map {
                $0.with(normal: $0.normal == .zero ? plane.normal : $0.normal)
            },
//            plane: plane,
            //isConvex: isConvex,
            material: material
        )
    }

}

private extension Polygon {
    final class Storage: Hashable {
        let vertices: [Vertex]
        //let plane: Plane
        //let isConvex: Bool
        var material: Material?

        static func == (lhs: Storage, rhs: Storage) -> Bool {
            lhs === rhs ||
                (lhs.vertices == rhs.vertices && lhs.material == rhs.material)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(vertices)
        }

        init(
            vertices: [Vertex],
            //plane: Plane,
            //isConvex: Bool,
            material: Material?
        ) {
            self.vertices = vertices
            //self.plane = plane
            //self.isConvex = isConvex
            self.material = material
        }
    }
}
