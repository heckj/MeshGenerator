//
//  Vertex.swift
//  
//
//  Created by Joseph Heck on 1/29/22.
//

import Foundation

public struct Vertex {
    public let position: Vector
    public let normal: Vector
    public let tex: TextureCoordinates
    
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
}
