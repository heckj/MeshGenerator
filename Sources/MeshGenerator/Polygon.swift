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

/// A struct that represents a unique polygon.
///
/// Polygon supports 3 or 4 vertices (triangles or quads), and requires that vertices specified as a quad be coplanar and convex.
public struct Polygon {
    typealias Material = AnyHashable
    /// The class for the storage of the relevant values and objects that make up the Polygon.
    private var storage: Storage
    
    /// The collection of vertices that make up the polygon.
    public var vertices: [Vertex] { storage.vertices }
    /// The plane that describes the polygon's face.
    var plane: Plane { storage.plane }
    /// The bounds of the polygon.
    public var bounds: Bounds { Bounds(points: vertices.map { $0.position }) }
    
    /// Creates a polygon from a set of vertices.
    ///
    /// A polygon can be convex or concave, but vertices must be coplanar and non-degenerate.
    /// Vertices are assumed to be in anti-clockwise order for the purpose of deriving the plane.
    init?(_ vertices: [Vertex], material: Material? = nil) {
        let positions = vertices.map { $0.position }
        let isConvex = Vertex.pointsAreConvex(positions)
        guard positions.count > 2,
              positions.count < 5,
              !Vertex.pointsAreSelfIntersecting(positions),
              isConvex == true,
              // Note: Plane init includes the check for degeneracy in the vertices
              let plane = Plane(points: positions)
        else {
            return nil
        }
        self.init(
            unchecked: vertices,
            plane: plane,
            sanitizeNormals: true,
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
    /// The points must represent a triangle or quad (3 or 4 points), be coplanar, convex, and non-degenerate.
    /// The points are assumed to be ordered in a counter-clockwise direction.
    ///
    /// - Parameters:
    ///   - points: The points making up the face of a polygon.
    ///   - convex: A Boolean value that indicates the points provided are convex.
    public static func faceNormalForPolygonPoints(_ points: [Vector]) -> Vector? {
        guard points.count > 2,
              points.count < 4 else {
                  return nil
              }
        switch points.count {
        case 3:
            return faceNormalForConvexPoints(points)
        default:
            guard Vertex.pointsAreCoplanar(points), Vertex.pointsAreConvex(points) else {
                return nil
            }
            return faceNormalForConvexPoints(points)
        }
    }
}

internal extension Polygon {
    /// Creates a polygon from vertices with no validation.
    ///
    /// Vertices must be convex, and are assumed to describe a non-degenerate polygon.
    /// Vertices are assumed to be in counter-clockwise order for the purpose of deriving the plane.
    ///
    /// The method includes asserts to verify the degeneracy and convex nature of the vertices provided,
    /// which will throw runtime exceptions when compiled in `DEBUG`.
    ///
    /// - Parameters:
    ///   - vertices: The list of vertices, in counter-clockwise order, that describe the polygon.
    ///   - sanitizeNormals: Whether to sanitize the normals for each of the vertices provided. Sanitizing normals sets the normals to ``Vector/zero`` or to the plane's normal value if it wasn't `zero`.
    ///   - material: The material, if provided, for the polygon.
    init(
        unchecked vertices: [Vertex],
        plane: Plane?,
        sanitizeNormals: Bool = false,
        material: Material?
    ) {
        assert(!Vertex.verticesAreDegenerate(vertices))
        assert(Vertex.verticesAreConvex(vertices) == true)
        assert(sanitizeNormals || vertices.allSatisfy { $0.normal != .zero })
        let plane = plane ?? Plane(unchecked: vertices.map { $0.position })
        self.storage = Storage(
            vertices: vertices.map {
                $0.with(normal: $0.normal == .zero ? plane.normal : $0.normal)
            },
            plane: plane,
            material: material
        )
    }
    
    /// Computes a normal for the provided points for a triangle or quad polygon.
    ///
    /// The points are assumed to be in counter-clockwise order for the purpose of deriving the plane.
    /// - Parameter points: The points that describe the polygon.
    /// - Returns: A normal vector for the polygon.
    static func faceNormalForConvexPoints(_ points: [Vector]) -> Vector {
        switch points.count {
        case 3:
            let ab = points[1] - points[0]
            let bc = points[2] - points[1]
            let normal = ab.cross(bc)
            return normal.normalized()
        default:
            let ab = points[1] - points[0]
            let bc = points[2] - points[1]
            let bd = points[3] - points[1]
            let normal1 = ab.cross(bc)
            let normal2 = ab.cross(bd)
            if normal1.lengthSquared > normal2.lengthSquared {
                return normal1.normalized()
            }
            return normal2.normalized()
        }
    }
}

private extension Polygon {
    final class Storage: Hashable {
        let vertices: [Vertex]
        let plane: Plane
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
            plane: Plane,
            material: Material?
        ) {
            self.vertices = vertices
            self.plane = plane
            self.material = material
        }
    }
}
