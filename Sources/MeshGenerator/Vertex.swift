//
//  Vertex.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//  Portions of the code were created by Nick Lockwood on 03/07/2018.
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

/// A struct that represents a vertex.
///
/// A vertex is comprised of a position in space, a vector that represents the normal for the vertex, the direction its facing, and a 2D coordinate to map to a texture associated with the vertex.
public struct Vertex: Hashable, Equatable {
    /// The position of the vertex.
    public let position: Vector
    /// The vertex's normal.
    public let normal: Vector
    /// The texture coordinates that this vertex maps to.
    public let tex: TextureCoordinates

    /// The `x` coordinate position of the vertex.
    public var x: Double {
        return position.x
    }

    /// The `y` coordinate position of the vertex.
    public var y: Double {
        return position.y
    }

    /// The `z` coordinate position of the vertex.
    public var z: Double {
        return position.z
    }

    /// Creates a new vertex.
    /// - Parameters:
    ///   - position: The position of the vertex.
    ///   - normal: The direction the vertex is facing.
    ///   - tex: The texture coordinates that this vertex maps to.
    public init(position: Vector, normal: Vector? = nil, tex: TextureCoordinates? = nil) {
        self.position = position
        if let normal = normal {
            self.normal = normal.normalized()
        } else {
            self.normal = .zero
        }
        if let tex = tex {
            self.tex = tex
        } else {
            self.tex = .zero
        }
    }
    
    /// Creates a new vertex with normal vector you provide.
    /// - Parameter normal: The normal to apply to the vertex.
    public func with(normal: Vector) -> Vertex {
        return Vertex(position: self.position, normal: normal, tex: tex)
    }

    /// Creates a new vertex.
    /// - Parameters:
    ///   - x: The `x` coordinate for the vertex.
    ///   - y: The `y` coordinate for the vertex.
    ///   - z: The `z` coordinate for the vertex.
    ///   - normal: The direction the vertex is facing.
    ///   - tex: The texture coordinates that this vertex maps to.
    public init(x: Double, y: Double, z: Double, normal: Vector? = nil, tex: TextureCoordinates? = nil) {
        self.init(position: Vector(x, y, z), normal: normal, tex: tex)
    }
    
    public static func verticesAreDegenerate(_ vertices: [Vertex]) -> Bool {
        guard vertices.count > 2 else {
            return true
        }
        let positions = vertices.map { $0.position }
        return pointsAreDegenerate(positions) || pointsAreSelfIntersecting(positions)
    }

    public static func verticesAreConvex(_ vertices: [Vertex]) -> Bool {
        guard vertices.count > 3 else {
            return vertices.count > 2
        }
        return pointsAreConvex(vertices.map { $0.position })
    }

    public static func verticesAreCoplanar(_ vertices: [Vertex]) -> Bool {
        if vertices.count < 4 {
            return true
        }
        return pointsAreCoplanar(vertices.map { $0.position })
    }

    static func pointsAreDegenerate(_ points: [Vector]) -> Bool {
        let count = points.count
        guard count > 2, var a = points.last else {
            return false
        }
        var ab = (points[0] - a).normalized()
        for i in 0 ..< count {
            let b = points[i]
            let c = points[(i + 1) % count]
            if b == c || a == b {
                return true
            }
            let bc = (c - b).normalized()
            guard abs(ab.dot(bc) + 1) > 0 else {
                return true
            }
            a = b
            ab = bc
        }
        return false
    }
    
    static func pointsAreConvex(_ points: [Vector]) -> Bool {
        let count = points.count
        guard count > 3, let a = points.last else {
            return count > 2
        }
        var normal: Vector?
        var ab = points[0] - a
        for i in 0 ..< count {
            let b = points[i]
            let c = points[(i + 1) % count]
            let bc = c - b
            var n = ab.cross(bc)
            let length = n.length
            // check result is large enough to be reliable
            if length > Vector.epsilon {
                n = n / length
                if let normal = normal {
                    if n.dot(normal) < 0 {
                        return false
                    }
                } else {
                    normal = n
                }
            }
            ab = bc
        }
        return true
    }
    
    // Test if path is self-intersecting
    // TODO: optimize by using http://www.webcitation.org/6ahkPQIsN
    static func pointsAreSelfIntersecting(_ points: [Vector]) -> Bool {
        guard points.count > 2 else {
            // A triangle can't be self-intersecting
            return false
        }
        for i in 0 ..< points.count - 2 {
            let p0 = points[i], p1 = points[i + 1]
            guard let l1 = LineSegment(p0, p1) else {
                continue
            }
            for j in i + 2 ..< points.count - 1 {
                let p2 = points[j], p3 = points[j + 1]
                guard !p1.isApproximatelyEqual(to: p2), !p1.isApproximatelyEqual(to: p3),
                      !p0.isApproximatelyEqual(to: p2), !p0.isApproximatelyEqual(to: p3),
                      let l2 = LineSegment(p2, p3)
                else {
                    continue
                }
                if l1.intersects(l2) {
                    return true
                }
            }
        }
        return false
    }

    static func pointsAreCoplanar(_ points: [Vector]) -> Bool {
        if points.count < 4 {
            return true
        }
        let b = points[1]
        let ab = b - points[0]
        let bc = points[2] - b
        let normal = ab.cross(bc)
        let length = normal.length
        if length < Vector.epsilon {
            return false
        }
        let plane = Plane(unchecked: normal / length, pointOnPlane: b)
        for p in points[3...] where !plane.containsPoint(p) {
            return false
        }
        return true
    }

}
