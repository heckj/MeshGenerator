//
//  Vector.swift
//  
//
//  Created by Joseph Heck on 1/29/22.
//

import Foundation
#if canImport(simd)
import simd
#endif

public struct Vector: Hashable {
    public let x: Double
    public let y: Double
    public let z: Double
#if canImport(simd)
    public var simd_float3: simd_float3 {
        return simd.simd_float3(Float(x), Float(y), Float(z))
    }
    public var simd_double3: simd_double3 {
        return simd.simd_double3(x, y, z)
    }
#endif
    
    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    public init(x: Float, y: Float, z: Float) {
        self.x = Double(x)
        self.y = Double(y)
        self.z = Double(z)
    }
    public init(x: Int, y: Int, z: Int) {
        self.x = Double(x)
        self.y = Double(y)
        self.z = Double(z)
    }
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
#if canImport(simd)
    public init(_ simdValue: simd_double3) {
        self.x = simdValue.x
        self.y = simdValue.y
        self.z = simdValue.z
    }
    public init(_ simdValue: simd_float3) {
        self.x = Double(simdValue.x)
        self.y = Double(simdValue.y)
        self.z = Double(simdValue.z)
    }
#endif

    
    /// A zero-length vector.
    public static let zero = Vector(0, 0, 0)
    
    public var length: Double {
#if canImport(simd)
        return simd_length(self.simd_double3)
#else
        return (self.dot(self)).squareRoot()
#endif
    }
    
    /// Computes the dot-product of this vector and another you provide.
    /// - Parameter another: The vector against which to compute a dot product.
    /// - Returns: A double that indicates the value to which one vector applies to another.
    public func dot(_ another: Vector) -> Double {
#if canImport(simd)
        return simd_dot(self.simd_double3, another.simd_double3)
#else
        x * a.x + y * a.y + z * a.z
#endif
    }
    
    /// Computes the cross-product of this vector and another you provide.
    /// - Parameter a: The vector against which to compute a cross product.
    /// - Returns: Returns a vector that is orthogonal to the two vectors used to compute the cross product.
    public func cross(_ other: Vector) -> Vector {
#if canImport(simd)
        return Vector(simd_cross(self.simd_double3, other.simd_double3))
#else
        Vector(
            y * another.z - z * other.y,
            z * other.x - x * other.z,
            x * other.y - y * other.x
        )
#endif
    }
    
    /// Returns a vector with its components divided by the value you provide.
    static func / (lhs: Vector, rhs: Double) -> Vector {
        Vector(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
    }
    
    /// Returns a vector with the values inverted.
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
