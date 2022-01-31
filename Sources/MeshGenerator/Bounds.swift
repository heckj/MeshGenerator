//
//  Bounds.swift
//  
//
//  Created by Joseph Heck on 1/29/22.
//  Copyright © 2022 Joseph Heck. All rights reserved.
//

import Foundation

/// A struct the represents the bounding volume in 3D space.
///
/// The bounds are defined as two ``MeshGenerator/Vector`` instances, that define the opposite corners of an axially aligned box.
public struct Bounds {
    public let min: Vector
    public let max: Vector
    
    static let empty = Bounds()

    /// Create a bounds with min and max points.
    ///
    /// If `max` < `min`, the bounds is considered to be empty.
    public init(min: Vector, max: Vector) {
        self.min = min
        self.max = max
    }
    
    /// Creates bounds by computing the max and min values from two points you provide.
    /// - Parameters:
    ///   - p0: The first point.
    ///   - p1: The second point.
    public init(_ p0: Vector, _ p1: Vector) {
        self.min = p0.min(p1)
        self.max = p0.max(p1)
    }
    
    /// Create bounds from an array of 3D points.
    /// - Parameter points: The list of ``MeshGenerator/Vector``.
    init(points: [Vector] = []) {
        var min = Vector(.infinity, .infinity, .infinity)
        var max = Vector(-.infinity, -.infinity, -.infinity)
        for p in points {
            min = min.min(p)
            max = max.max(p)
        }
        self.min = min
        self.max = max
    }
    
    init(polygons: [Triangle]) {
        var min = Vector(.infinity, .infinity, .infinity)
        var max = Vector(-.infinity, -.infinity, -.infinity)
        for p in polygons {
            for v in p.vertices {
                min = min.min(v.position)
                max = max.max(v.position)
            }
        }
        self.min = min
        self.max = max
    }

    /// Whether the maximum is greater than the minimum.
    public var hasNegativeVolume: Bool {
        max.x < min.x || max.y < min.y || max.z < min.z
    }
    
    /// Whether the volume of the bounding box is zero.
    ///
    /// A bounding volume that was created with a negative volume reports `true`.
    public var isEmpty: Bool {
        size == .zero
    }

    /// A vector that represents the size of the bounding volume.
    ///
    /// A bounding volume that was created with negative volume is ``MeshGenerator/Vector/zero``.
    public var size: Vector {
        hasNegativeVolume ? .zero : max - min
    }
    
    /// A vector that represents the center of the bounding box.
    ///
    /// A bounding volume that was created with negative volume is ``MeshGenerator/Vector/zero``.
    public var center: Vector {
        hasNegativeVolume ? .zero : min + size / 2
    }
    
    /// Returns a Boolean value that indicates whether the point you provide is within the bounding box volume.
    /// - Parameter p: The point to compare to the bounds.
    public func containsPoint(_ p: Vector) -> Bool {
        p.x >= min.x && p.x <= max.x &&
            p.y >= min.y && p.y <= max.y &&
            p.z >= min.z && p.z <= max.z
    }

}
