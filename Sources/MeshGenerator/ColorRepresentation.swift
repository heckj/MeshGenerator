//
//  ColorRepresentation.swift
//
//
//  Created by Joseph Heck on 1/30/22.
//  Copyright © 2022 Joseph Heck. All rights reserved.
//

import Foundation

/// A struct that represents a color using red, green, blue, and alpha values.
///
public struct ColorRepresentation: Equatable, Hashable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    /// Creates a new color representation using the RGB values you provide.
    /// - Parameters:
    ///   - r: The red value, from 0 to 1.0.
    ///   - g: The green value, from 0 to 1.0
    ///   - b: The blue value, from 0 to 1.0
    public init(_ r: Double, _ g: Double, _ b: Double) {
        precondition(r >= 0 && r <= 1.0 && g >= 0 && g <= 1.0 && b >= 0 && b <= 1.0)
        red = r
        green = g
        blue = b
        alpha = 1.0
    }

    /// Creates a new gray color representation with the alpha value you provide
    /// - Parameters:
    ///   - x: The grey tone value, from 0 to 1.0.
    ///   - a: The alpha value, from 0 to 1.0.
    public init(_ x: Double, _ a: Double) {
        precondition(x <= 1.0 && a <= 1.0 && x >= 0 && a >= 0)
        red = x
        green = x
        blue = x
        alpha = a
    }

    /// Creates a new color representation using the red, green, blue and alpha values you provide.
    /// - Parameters:
    ///   - red: The red value, from 0 to 1.0.
    ///   - green: The green value, from 0 to 1.0.
    ///   - blue: The blue value, from 0 to 1.0.
    ///   - alpha: The alpha value, from 0 to 1.0.
    public init(_ red: Double, _ green: Double, _ blue: Double, _ alpha: Double) {
        precondition(red >= 0 && red <= 1.0 && green >= 0 && green <= 1.0 && blue >= 0 && blue <= 1.0 && alpha >= 0 && alpha <= 1.0)
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    static var clear = ColorRepresentation(0, 0)
    static var black = ColorRepresentation(0, 1)
    static var white = ColorRepresentation(1, 0)
    static let gray = ColorRepresentation(0.5, 1)
    static var red = ColorRepresentation(1, 0, 0)
    static var green = ColorRepresentation(0, 1, 0)
    static var blue = ColorRepresentation(0, 0, 1)
    static let yellow = ColorRepresentation(1, 1, 0)
    static let cyan = ColorRepresentation(0, 1, 1)
    static let magenta = ColorRepresentation(1, 0, 1)
    static let orange = ColorRepresentation(1, 0.5, 0)
}
