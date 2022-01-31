//
//  Vertex.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//  Copyright © 2022 Joseph Heck. All rights reserved.
//
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
        return Vertex(position: position, normal: normal, tex: tex)
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

    /// Invert all orientation-specific data (e.g. vertex normal). Called when the
    /// orientation of a polygon is flipped.
    func inverted() -> Vertex {
        Vertex(position: position, normal: -normal, tex: tex)
    }

    /// Linearly interpolate between two vertices.
    ///
    /// Interpolation is applied to the position, texture coordinate and normal.
    func lerp(_ other: Vertex, _ t: Double) -> Vertex {
        Vertex(
            position: position.lerp(other.position, t),
            normal: normal.lerp(other.normal, t),
            tex: tex.lerp(other.tex, t)
        )
    }
}
