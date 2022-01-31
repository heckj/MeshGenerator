//
//  Polygon.swift
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

/// A struct that represents a unique polygon.
///
/// Polygon supports 3 or 4 vertices (triangles or quads), and requires that vertices specified as a quad be coplanar and convex.
public struct Polygon: Hashable {
    public typealias Material = AnyHashable
    /// The class for the storage of the relevant values and objects that make up the Polygon.
    private var storage: Storage
    
    /// The collection of vertices that make up the polygon.
    public var vertices: [Vertex] { storage.vertices }
    /// The plane that describes the polygon's face.
    var plane: Plane { storage.plane }
    /// The material associated with the polygon.
    var material: Material? { storage.material }
    /// The bounds of the polygon.
    public var bounds: Bounds { Bounds(points: vertices.map { $0.position }) }
    
    /// Creates a polygon from a set of vertices.
    ///
    /// A polygon can be convex or concave, but vertices must be coplanar and non-degenerate.
    /// Vertices are assumed to be in anti-clockwise order for the purpose of deriving the plane.
    public init?(_ vertices: [Vertex], material: Material? = nil) {
        let positions = vertices.map { $0.position }
        
        guard positions.count > 2,
              positions.count < 5,
              let plane = Plane(points: positions),
                // Note: Plane init includes the check for degeneracy, coplanar, and convex in the vertices
              !Vertex.pointsAreSelfIntersecting(positions)
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
    /// - Parameters:
    ///   - vertices: The points making up the face of a polygon.
    ///   - material: The material to use for rendering the polygon.
    public init?(_ vertices: [Vector], material: Material? = nil) {
        self.init(vertices.map { Vertex(position: $0) }, material: material)
    }
    
    /// Indicates whether the polygon includes texture coordinates.
    var hasTexcoords: Bool {
        vertices.contains(where: { $0.tex != .zero })
    }

    /// Creates a new polygon with material you provide.
    /// - Parameter normal: The normal to apply to the vertex.
    public func with(material: Material?) -> Polygon {
        return Polygon(unchecked: vertices, plane: plane, material: material)
    }

    /// Returns a set of polygon edges.
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

    /// Returns a vector that is the face normal direction for the list of points you provide.
    ///
    /// The points must represent a triangle or quad (3 or 4 points), be coplanar, convex, and non-degenerate.
    /// The points are assumed to be ordered in a counter-clockwise direction for the purposes of computing the direction of the normal.
    ///
    /// - Parameters:
    ///   - points: The points making up the face of a polygon.
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
    
    /// Flips the polygon along its plane.
    func inverted() -> Polygon {
        Polygon(
            unchecked: vertices.reversed().map { $0.inverted() },
            plane: plane.inverted(),
            material: material
        )
    }

    /// Returns a Boolean value that indicates whether a point lies inside the polygon.
    func containsPoint(_ p: Vector) -> Bool {
        return plane.containsPoint(p)
//        guard plane.containsPoint(p) else {
//            return false
//        }
//        // https://stackoverflow.com/questions/217578/how-can-i-determine-whether-a-2d-point-is-within-a-polygon#218081
//        let flatteningPlane = FlatteningPlane(normal: plane.normal)
//        let points = vertices.map { flatteningPlane.flattenPoint($0.position) }
//        let p = flatteningPlane.flattenPoint(p)
//        let count = points.count
//        var c = false
//        var j = count - 1
//        for i in 0 ..< count {
//            if (points[i].y > p.y) != (points[j].y > p.y),
//               p.x < (points[j].x - points[i].x) * (p.y - points[i].y) /
//               (points[j].y - points[i].y) + points[i].x
//            {
//                c = !c
//            }
//            j = i
//        }
//        return c
    }

//    /// Converts a concave polygon into 2 or more convex polygons using the "ear clipping" method.
//    func tessellate() -> [Polygon] {
//        if isConvex {
//            return [self]
//        }
//        var polygons = triangulate()
//        var i = polygons.count - 1
//        while i > 0 {
//            let a = polygons[i]
//            let b = polygons[i - 1]
//            if let merged = a.merge(unchecked: b, ensureConvex: true) {
//                polygons[i - 1] = merged
//                polygons.remove(at: i)
//            }
//            i -= 1
//        }
//        return polygons
//    }

//    /// Tessellates polygon into triangles using the "ear clipping" method.
//    func triangulate() -> [Polygon] {
//        guard vertices.count > 3 else {
//            return [self]
//        }
//        return triangulateVertices(
//            vertices,
//            plane: plane,
//            isConvex: isConvex,
//            material: material,
//            id: id
//        )
//    }
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
    
//    static func triangulateVertices(
//        _ vertices: [Vertex],
//        plane: Plane?,
//        isConvex: Bool?,
//        material: Mesh.Material?,
//        id: Int
//    ) -> [Polygon] {
//        var vertices = vertices
//        guard vertices.count > 3 else {
//            assert(vertices.count > 2)
//            return [Polygon(
//                unchecked: vertices,
//                plane: plane,
//                material: material
//            )]
//        }
//        var triangles = [Polygon]()
//        func addTriangle(_ vertices: [Vertex]) -> Bool {
//            guard !Vertex.verticesAreDegenerate(vertices) else {
//                return false
//            }
//            triangles.append(Polygon(
//                unchecked: vertices,
//                plane: plane,
//                material: material
//            ))
//            return true
//        }
//        let positions = vertices.map { $0.position }
//        if isConvex ?? Vertex.pointsAreConvex(positions) {
//            let v0 = vertices[0]
//            var v1 = vertices[1]
//            for v2 in vertices[2...] {
//                _ = addTriangle([v0, v1, v2])
//                v1 = v2
//            }
//            return triangles
//        }
//
//        // Note: this solves a problem when anticlockwise-ordered concave polygons
//        // would be incorrectly triangulated. However it's not clear why this is
//        // necessary, or if it will do the correct thing in all circumstances
//        let flatteningPlane = FlatteningPlane(
//            normal: plane?.normal ??
//                faceNormalForPolygonPoints(positions, convex: false)
//        )
//        let flattenedPoints = vertices.map { flatteningPlane.flattenPoint($0.position) }
//        let isClockwise = flattenedPointsAreClockwise(flattenedPoints)
//        if !isClockwise {
//            guard flattenedPointsAreClockwise(flattenedPoints.reversed()) else {
//                // Points are self-intersecting, or otherwise degenerate
//                return []
//            }
//            return triangulateVertices(
//                vertices.reversed().map { $0.inverted() },
//                plane: plane?.inverted(),
//                isConvex: isConvex,
//                material: material,
//                id: id
//            ).inverted()
//        }
//
//        var i = 0
//        var attempts = 0
//        func removeVertex() {
//            attempts = 0
//            vertices.remove(at: i)
//            if i == vertices.count {
//                i = 0
//            }
//        }
//        while vertices.count > 3 {
//            let p0 = vertices[(i - 1 + vertices.count) % vertices.count]
//            let p1 = vertices[i]
//            let p2 = vertices[(i + 1) % vertices.count]
//            // check for colinear points
//            let p0p1 = p0.position - p1.position, p2p1 = p2.position - p1.position
//            if p0p1.cross(p2p1).length < Vector.epsilon {
//                // vertices are colinear, so we can't form a triangle
//                if p0p1.dot(p2p1) > 0 {
//                    // center point makes path degenerate - remove it
//                    removeVertex()
//                } else {
//                    // try next point instead
//                    i += 1
//                    if i == vertices.count {
//                        i = 0
//                        attempts += 1
//                        if attempts > 2 {
//                            return triangles
//                        }
//                    }
//                }
//                continue
//            }
//            let triangle = Polygon([p0, p1, p2])
//            if triangle == nil || vertices.contains(where: {
//                !triangle!.vertices.contains($0) && triangle!.containsPoint($0.position)
//            }) || plane.map({ triangle!.plane.normal.dot($0.normal) <= 0 }) ?? false {
//                i += 1
//                if i == vertices.count {
//                    i = 0
//                    attempts += 1
//                    if attempts > 2 {
//                        return triangles
//                    }
//                }
//            } else if addTriangle(triangle!.vertices) {
//                removeVertex()
//            }
//        }
//        _ = addTriangle(vertices)
//        return triangles
//    }

}

internal extension Collection where Element == Polygon {
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
        for polygon in self {
            for edge in polygon.undirectedEdges {
                edgeCounts[edge, default: 0] += 1
            }
        }
        return edgeCounts.values.allSatisfy { $0 >= 2 && $0 % 2 == 0 }
    }

//    /// Insert missing vertices needed to prevent hairline cracks
//    func makeWatertight() -> [Polygon] {
//        var polygonsByEdge = [LineSegment: Int]()
//        for polygon in self {
//            for edge in polygon.undirectedEdges {
//                polygonsByEdge[edge, default: 0] += 1
//            }
//        }
//        var points = Set<Vector>()
//        let edges = polygonsByEdge.filter { !$0.value.isMultiple(of: 2) }.keys
//        for edge in edges.sorted() {
//            points.insert(edge.start)
//            points.insert(edge.end)
//        }
//        var polygons = Array(self)
//        let sortedPoints = points.sorted()
//        for i in polygons.indices {
//            let bounds = polygons[i].bounds.inset(by: -Vector.epsilon)
//            for point in sortedPoints where bounds.containsPoint(point) {
//                _ = polygons[i].insertEdgePoint(point)
//            }
//        }
//        return polygons
//    }

    /// Flip each polygon along its plane
    func inverted() -> [Polygon] {
        map { $0.inverted() }
    }

//    /// Decompose each concave polygon into 2 or more convex polygons
//    func tessellate() -> [Polygon] {
//        flatMap { $0.tessellate() }
//    }
//
//    /// Decompose each polygon into triangles
//    func triangulate() -> [Polygon] {
//        flatMap { $0.triangulate() }
//    }

//    /// Merge coplanar polygons that share one or more edges
//    /// Note: polygons must be sorted by plane prior to calling this method
//    func detessellate(ensureConvex: Bool = false) -> [Polygon] {
//        var polygons = Array(self)
//        assert(polygons.areSortedByPlane)
//        var i = 0
//        var firstPolygonInPlane = 0
//        while i < polygons.count {
//            var j = i + 1
//            let a = polygons[i]
//            while j < polygons.count {
//                let b = polygons[j]
//                guard a.plane.isEqual(to: b.plane) else {
//                    firstPolygonInPlane = j
//                    i = firstPolygonInPlane - 1
//                    break
//                }
//                if let merged = a.merge(b, ensureConvex: ensureConvex) {
//                    polygons[i] = merged
//                    polygons.remove(at: j)
//                    i = firstPolygonInPlane - 1
//                    break
//                }
//                j += 1
//            }
//            i += 1
//        }
//        return polygons
//    }

    /// Sort polygons by plane
    func sortedByPlane() -> [Polygon] {
        sorted(by: { $0.plane < $1.plane })
    }

    /// Returns a dictionary of polygons, keyed to the material used by the polygon.
    func groupedByMaterial() -> [Polygon.Material?: [Polygon]] {
        var polygonsByMaterial = [Polygon.Material?: [Polygon]]()
        forEach { polygonsByMaterial[$0.material, default: []].append($0) }
        return polygonsByMaterial
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
