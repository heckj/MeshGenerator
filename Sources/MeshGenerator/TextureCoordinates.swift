//
//  TextureCoordinates.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//  Copyright © 2022 Joseph Heck. All rights reserved.
//

import Foundation
#if canImport(simd)
    import simd
#endif

/// A struct that represents texture coordinates.
public struct TextureCoordinates: Hashable, Sendable {
    /// The `u` coordinate.
    public let u: Double
    /// The `v` coordinate.
    public let v: Double
    #if canImport(simd)
        /// The coordinates represented as a 2 float vector with `simd` from the Accelerate framework.
        public var simd_float2: simd_float2 {
            return simd.simd_float2(Float(u), Float(v))
        }

        /// The coordinates represented as a 2 double vector with `simd` from the Accelerate framework.
        public var simd_double2: simd_double2 {
            return simd.simd_double2(u, v)
        }
    #endif

    /// Creates a new texture coordinate.
    /// - Parameters:
    ///   - u: The `u` coordinate.
    ///   - v: The `v` coordinate.
    public init(_ u: Double, _ v: Double) {
        self.u = u
        self.v = v
    }

    /// Creates a new texture coordinate.
    /// - Parameters:
    ///   - u: The `u` coordinate.
    ///   - v: The `v` coordinate.
    public init(u: Float, v: Float) {
        self.u = Double(u)
        self.v = Double(v)
    }

    /// Creates a new texture coordinate.
    /// - Parameters:
    ///   - u: The `u` coordinate.
    ///   - v: The `v` coordinate.
    public init(u: Int, v: Int) {
        self.u = Double(u)
        self.v = Double(v)
    }

    /// Creates a new texture coordinate.
    /// - Parameters:
    ///   - u: The `u` coordinate.
    ///   - v: The `v` coordinate.
    public init(u: Double, v: Double) {
        self.u = u
        self.v = v
    }

    /// Returns a texture coordinate with its components multiplied by the value you provide.
    /// - Parameters:
    ///   - lhs: The first coordinate.
    ///   - rhs: The second coordinate.
    static func * (lhs: TextureCoordinates, rhs: Double) -> TextureCoordinates {
        TextureCoordinates(lhs.u * rhs, lhs.v * rhs)
    }

    /// Returns a texture coordinate with its components multiplied by the value you provide.
    /// - Parameters:
    ///   - lhs: The first coordinate.
    ///   - rhs: The second coordinate.
    static func * (lhs: Double, rhs: TextureCoordinates) -> TextureCoordinates {
        TextureCoordinates(lhs * rhs.u, lhs * rhs.v)
    }

    /// Returns a texture coordinate that is the sum of the coordinates you provide.
    /// - Parameters:
    ///   - lhs: The first coordinate.
    ///   - rhs: The second coordinate.
    public static func + (lhs: TextureCoordinates, rhs: TextureCoordinates) -> TextureCoordinates {
        TextureCoordinates(lhs.u + rhs.u, lhs.v + rhs.v)
    }

    /// Returns a texture coordinate that is the difference of the coordinates you provide.
    /// - Parameters:
    ///   - lhs: The first coordinate.
    ///   - rhs: The second coordinate.
    public static func - (lhs: TextureCoordinates, rhs: TextureCoordinates) -> TextureCoordinates {
        TextureCoordinates(lhs.u - rhs.u, lhs.v - rhs.v)
    }

    /// Linearly interpolate between this texture coordinate and another you provide.
    /// - Parameters:
    ///   - a: The coordinate to interpolate towards.
    ///   - t: A value, typically between `0` and `1`, to indicate the position  to interpolate between the two coordinates.
    /// - Returns: A texture coordinate interpolated to the position you provide.
    public func lerp(_ a: TextureCoordinates, _ t: Double) -> TextureCoordinates {
        self + (a - self) * t
    }

    /// A texture coordinate at the position `(0,0)`
    public static let zero = TextureCoordinates(0, 0)
    /// A texture coordinate at the position `(1,1)`
    public static let one = TextureCoordinates(1, 1)
}

extension TextureCoordinates: Comparable {
    /// Returns a Boolean value that compares two vectors to provide a stable sort order.
    public static func < (lhs: TextureCoordinates, rhs: TextureCoordinates) -> Bool {
        if lhs.u < rhs.u {
            return true
        } else if lhs.u > rhs.u {
            return false
        }
        return lhs.v < rhs.v
    }
}
