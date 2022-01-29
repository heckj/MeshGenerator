//
//  Vertex.swift
//  
//
//  Created by Joseph Heck on 1/29/22.
//

import Foundation

/// A struct that represents a vertex.
///
/// A vertex is comprised of a position in space, a vector that represents the normal for the vertex, the direction its facing, and a 2D coordinate to map to a texture associated with the vertex.
public struct Vertex {
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

    /// Creates a new vertex.
    /// - Parameters:
    ///   - x: The `x` coordinate for the vertex.
    ///   - y: The `y` coordinate for the vertex.
    ///   - z: The `z` coordinate for the vertex.
    ///   - normal: The direction the vertex is facing.
    ///   - tex: The texture coordinates that this vertex maps to.
    public init(x: Double, y: Double, z: Double, normal: Vector? = nil, tex: TextureCoordinates? = nil) {
        self.init(position: Vector(x,y,z), normal: normal, tex: tex)
    }

}
