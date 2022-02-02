//
//  Vector.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//  Copyright © 2022 Joseph Heck. All rights reserved.
//

import Foundation
#if canImport(simd)
    import simd
#endif

/// A struct that represents a vector in 3D space.
public struct Vector: Hashable {
    /// The `x` coordinate.
    public let x: Double
    /// The `y` coordinate.
    public let y: Double
    /// The `z` coordinate.
    public let z: Double
    #if canImport(simd)
        /// The coordinates represented as a 3 float vector with `simd` from the Accelerate framework.
        ///
        /// This value may loose precision from the Vector's internal values, which are stored and processed as `Double`.
        public var simd_float3: simd_float3 {
            return simd.simd_float3(Float(x), Float(y), Float(z))
        }

        /// The coordinates represented as a 3 double vector with with `simd` from the Accelerate framework.
        public var simd_double3: simd_double3 {
            return simd.simd_double3(x, y, z)
        }
    #endif

    /// Tolerance for determining minimum or nearly-equivalent lengths for vectors.
    ///
    /// The built-in value for this library is `1e-8`.
    public static let epsilon = 1e-8

    /// Creates a new vector
    /// - Parameters:
    ///   - x: The `x` coordinate.
    ///   - y: The `y` coordinate.
    ///   - z: The `z` coordinate.
    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    /// Creates a new vector
    /// - Parameters:
    ///   - x: The `x` coordinate.
    ///   - y: The `y` coordinate.
    ///   - z: The `z` coordinate.
    public init(x: Float, y: Float, z: Float) {
        self.x = Double(x)
        self.y = Double(y)
        self.z = Double(z)
    }

    /// Creates a new vector
    /// - Parameters:
    ///   - x: The `x` coordinate.
    ///   - y: The `y` coordinate.
    ///   - z: The `z` coordinate.
    public init(x: Int, y: Int, z: Int) {
        self.x = Double(x)
        self.y = Double(y)
        self.z = Double(z)
    }

    /// Creates a new vector
    /// - Parameters:
    ///   - x: The `x` coordinate.
    ///   - y: The `y` coordinate.
    ///   - z: The `z` coordinate.
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    #if canImport(simd)
        /// Creates a new vector
        /// - Parameters:
        ///   - simdValue: The coordinate values..
        public init(_ simdValue: simd_double3) {
            x = simdValue.x
            y = simdValue.y
            z = simdValue.z
        }

        /// Creates a new vector
        /// - Parameters:
        ///   - simdValue: The coordinate values..
        public init(_ simdValue: simd_float3) {
            x = Double(simdValue.x)
            y = Double(simdValue.y)
            z = Double(simdValue.z)
        }
    #endif

    /// A zero-length vector.
    public static let zero = Vector(0, 0, 0)

    /// The length of the vector.
    public var length: Double {
        #if canImport(simd)
            return simd_length(simd_double3)
        #else
            return (dot(self)).squareRoot()
        #endif
    }

    /// The square of the length.
    ///
    /// Use `lengthSquared` over `length` if you're able for repeated calculations, because this is a faster computation.
    public var lengthSquared: Double {
        #if canImport(simd)
            return simd_length_squared(simd_double3)
        #else
            return (dot(self))
        #endif
    }

    /// A Boolean value indicating that the length of the vector is `1`.
    public var isNormalized: Bool {
        #if canImport(simd)
            abs(simd_length_squared(simd_double3) - 1.0) < Vector.epsilon
        #else
            abs(dot(self) - 1) < Vector.epsilon
        #endif
    }

    /// Computes the dot-product of this vector and another you provide.
    /// - Parameter other: The vector against which to compute a dot product.
    /// - Returns: A double that indicates the value to which one vector applies to another.
    public func dot(_ another: Vector) -> Double {
        #if canImport(simd)
            return simd_dot(simd_double3, another.simd_double3)
        #else
            x * a.x + y * a.y + z * a.z
        #endif
    }

    /// Computes the cross-product of this vector and another you provide.
    /// - Parameter other: The vector against which to compute a cross product.
    /// - Returns: Returns a vector that is orthogonal to the two vectors used to compute the cross product.
    public func cross(_ other: Vector) -> Vector {
        #if canImport(simd)
            return Vector(simd_cross(simd_double3, other.simd_double3))
        #else
            Vector(
                y * another.z - z * other.y,
                z * other.x - x * other.z,
                x * other.y - y * other.x
            )
        #endif
    }

    /// Returns a vector with its components divided by the value you provide.
    /// - Parameters:
    ///   - lhs: The first vector.
    ///   - rhs: The second vector.
    static func / (lhs: Vector, rhs: Double) -> Vector {
        Vector(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }

    /// Returns a vector with its components divided by the value you provide.
    /// - Parameters:
    ///   - lhs: The first vector.
    ///   - rhs: The second vector.
    static func * (lhs: Vector, rhs: Double) -> Vector {
        Vector(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }

    /// Returns a vector with the values inverted.
    /// - Parameter rhs: The vector to invert.
    static prefix func - (rhs: Vector) -> Vector {
        Vector(-rhs.x, -rhs.y, -rhs.z)
    }

    /// Returns a vector that is the sum of the vectors you provide.
    /// - Parameters:
    ///   - lhs: The first vector.
    ///   - rhs: The second vector.
    public static func + (lhs: Vector, rhs: Vector) -> Vector {
        Vector(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    /// Returns a vector that is the difference of the vectors you provide.
    /// - Parameters:
    ///   - lhs: The first vector.
    ///   - rhs: The second vector.
    public static func - (lhs: Vector, rhs: Vector) -> Vector {
        Vector(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }

    /// Returns a normalized vector with a length of one.
    public func normalized() -> Vector {
        let length = self.length
        return length == 0 ? .zero : self / length
    }

    /// Returns the maximum value for any of the coordinates within the vector.
    public func max() -> Double {
        Swift.max(x, y, z)
    }

    /// Returns the minimum value for any of the coordinates within the vector.
    public func min() -> Double {
        Swift.min(x, y, z)
    }

    /// Returns a new vector that represents the mininum value for each of the components of the two vectors.
    /// - Parameter rhs: The vector to compare.
    public func min(_ rhs: Vector) -> Vector {
        Vector(Swift.min(x, rhs.x), Swift.min(y, rhs.y), Swift.min(z, rhs.z))
    }

    /// Returns a new vector that represents the maximum value for each of the components of the two vectors.
    /// - Parameter rhs: The vector to compare.
    public func max(_ rhs: Vector) -> Vector {
        Vector(Swift.max(x, rhs.x), Swift.max(y, rhs.y), Swift.max(z, rhs.z))
    }

    /// Returns the distance to another point in space.
    /// - Parameter other: The point in space to compare.
    public func distance(from other: Vector) -> Double {
        (self - other).length
    }

    /// Returns a Boolean value that indicates whether the two vectors are equivalent within a known level of precision.
    /// - Parameters:
    ///   - other: The vector to compare.
    ///   - p: The precision to use in determining if the values are close enough to be considered equal, defaulting to ``MeshGenerator/Vector/epsilon``.
    public func isApproximatelyEqual(to other: Vector, withPrecision p: Double = epsilon) -> Bool {
        self == other || (
            x.isApproximatelyEqual(to: other.x, withPrecision: p) &&
                y.isApproximatelyEqual(to: other.y, withPrecision: p) &&
                z.isApproximatelyEqual(to: other.z, withPrecision: p)
        )
    }

    /// Linearly interpolate between this vector and another you provide.
    /// - Parameters:
    ///   - a: The vector to interpolate towards.
    ///   - t: A value, typically between `0` and `1`, to indicate the position  to interpolate between the two vectors.
    /// - Returns: A vector interpolated to the position you provide.
    public func lerp(_ a: Vector, _ t: Double) -> Vector {
        self + (a - self) * t
    }
}

extension Vector: Comparable {
    /// Returns a Boolean value that compares two vectors to provide a stable sort order.
    public static func < (lhs: Vector, rhs: Vector) -> Bool {
        if lhs.x < rhs.x {
            return true
        } else if lhs.x > rhs.x {
            return false
        }
        if lhs.y < rhs.y {
            return true
        } else if lhs.y > rhs.y {
            return false
        }
        return lhs.z < rhs.z
    }
}

extension Double {
    func isApproximatelyEqual(to other: Double, withPrecision p: Double) -> Bool {
        abs(self - other) < p
    }
}
