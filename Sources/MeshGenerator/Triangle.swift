//
//  Triangle.swift
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

import Foundation

/// A struct that represents a triangle in 3D space.
public struct Triangle: Hashable {
    public typealias Material = AnyHashable
    /// The class for the storage of the relevant values and objects that make up the triangle.
    private var storage: Storage

    /// The collection of vertices that make up the triangle.
    public var vertices: [Vertex] { storage.vertices }
    /// The plane that describes the triangle's face.
    var plane: Plane { storage.plane }
    /// The material associated with the triangle.
    var material: Material? { storage.material }
    /// The bounds of the triangle.
    public var bounds: Bounds { Bounds(points: vertices.map { $0.position }) }

    /// Creates a triangle from a set of vertices.
    ///
    /// A polygon can be convex or concave, but vertices must be coplanar and non-degenerate.
    /// Vertices are assumed to be in anti-clockwise order for the purpose of deriving the plane.
    public init?(_ vertices: [Vertex], material: Material? = nil) {
        let positions = vertices.map { $0.position }

        guard positions.count == 3,
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

    /// Creates a triangle from a set of vertex positions.
    ///
    /// Vertex normals will be set to match face normal based on the positions being listed in a counter-clockwise direction..
    /// - Parameters:
    ///   - vertices: The points making up the face of a polygon.
    ///   - material: The material to use for rendering the polygon.
    public init?(_ vertices: [Vector], material: Material? = nil) {
        self.init(vertices.map { Vertex(position: $0) }, material: material)
    }

    /// Creates a triangle from a tuple of three vector positions.
    ///
    /// Vertex normals will be set to match face normal based on the positions being listed in a counter-clockwise direction.
    /// - Parameters:
    ///   - vertices: The points making up the face of a polygon.
    ///   - material: The material to use for rendering the polygon.
    public init(_ vertices: (Vector, Vector, Vector), material: Material? = nil) {
        self.init(unchecked: [Vertex(position: vertices.0), Vertex(position: vertices.1), Vertex(position: vertices.2)],
                  plane: nil,
                  sanitizeNormals: true,
                  material: material)

    }

    /// Creates a triangle from a tuple of three vector positions.
    ///
    /// Vertex normals will be set to match face normal based on the positions being listed in a counter-clockwise direction.
    /// - Parameters:
    ///   - vertices: The points making up the face of a polygon.
    ///   - material: The material to use for rendering the polygon.
    public init(_ v1: Vector, _ v2: Vector, _ v3: Vector, material: Material? = nil) {
        self.init(unchecked: [Vertex(position: v1), Vertex(position: v2), Vertex(position: v3)],
                  plane: nil,
                  sanitizeNormals: true,
                  material: material)
    }

    /// Indicates whether the triangle includes texture coordinates.
    var hasTexcoords: Bool {
        vertices.contains(where: { $0.tex != .zero })
    }

    /// Creates a new triangle with material you provide.
    /// - Parameter normal: The normal to apply to the vertex.
    public func with(material: Material?) -> Triangle {
        return Triangle(unchecked: vertices, plane: plane, material: material)
    }

    /// Returns a set of triangle edges.
    ///
    /// The direction of each edge is normalized relative to the origin to facilitate edge-equality comparisons.
    var undirectedEdges: Set<LineSegment> {
        var p0 = vertices.last!.position
        return Set(vertices.map {
            let p1 = $0.position
            defer { p0 = p1 }
            return LineSegment(normalized: p0, p1)
        })
    }

    /// Flips the triangle along its plane.
    func inverted() -> Triangle {
        Triangle(
            unchecked: vertices.reversed().map { $0.inverted() },
            plane: plane.inverted(),
            material: material
        )
    }

    /// Returns a Boolean value that indicates whether a point lies inside the polygon.
    func containsPoint(_ p: Vector) -> Bool {
        return plane.containsPoint(p)
    }
}

internal extension Triangle {
    /// Creates a triangle from vertices with no validation.
    ///
    /// Vertices are assumed to be in counter-clockwise order for the purpose of deriving the plane.
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
        assert(sanitizeNormals || vertices.allSatisfy { $0.normal != .zero })
        let plane = plane ?? Plane(unchecked: vertices.map { $0.position })
        storage = Storage(
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

internal extension Collection where Element == Triangle {
    /// Return a set of all unique edges across all the polygons
    var uniqueEdges: Set<LineSegment> {
        var edges = Set<LineSegment>()
        forEach { edges.formUnion($0.undirectedEdges) }
        return edges
    }

    /// Check if polygons form a watertight mesh, i.e. every edge is attached to at least 2 polygons.
    /// Note: doesn't verify that mesh is not self-intersecting or inside-out.
    var areWatertight: Bool {
        var edgeCounts = [LineSegment: Int]()
        for triangle in self {
            for edge in triangle.undirectedEdges {
                edgeCounts[edge, default: 0] += 1
            }
        }
        return edgeCounts.values.allSatisfy { $0 >= 2 && $0 % 2 == 0 }
    }

    /// Flip each polygon along its plane
    func inverted() -> [Triangle] {
        map { $0.inverted() }
    }

    /// Sort polygons by plane
    func sortedByPlane() -> [Triangle] {
        sorted(by: { $0.plane < $1.plane })
    }

    /// Returns a dictionary of polygons, keyed to the material used by the polygon.
    func groupedByMaterial() -> [Triangle.Material?: [Triangle]] {
        var polygonsByMaterial = [Triangle.Material?: [Triangle]]()
        forEach { polygonsByMaterial[$0.material, default: []].append($0) }
        return polygonsByMaterial
    }
}

private extension Triangle {
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
