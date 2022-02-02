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
    
    /// A clear color.
    ///
    /// The values for clear are (`0,0`, `0,0`, `00`) with an alpha value of `0.0`.
    public static var clear = ColorRepresentation(0, 0)
    
    /// The color black.
    ///
    /// The values for black are (`0.0`, `0.0`, `0.0`) with an alpha value of `1.0`.
    public static var black = ColorRepresentation(0, 1)

    /// The color white.
    ///
    /// The values for white are (`1.0`, `1.0`, `1.0`) with an alpha value of `1.0`.
    public static var white = ColorRepresentation(1, 0)

    /// The color gray.
    ///
    /// The values for gray are  (`0.5`, `0.5`, `0.5`) with an alpha value of `1.0`.
    public static let gray = ColorRepresentation(0.5, 1)

    /// The color red.
    ///
    /// The values for red are  (`1.0`, `0.0`, `0.0`) with an alpha value of `1.0`.
    public static var red = ColorRepresentation(1, 0, 0)

    /// The color green.
    ///
    /// The values for green are  (`0.0`, `1.0`, `0.0`) with an alpha value of `1.0`.
    public static var green = ColorRepresentation(0, 1, 0)

    /// The color blue.
    ///
    /// The values for blue are  (`0.0`, `0.0`, `1.0`) with an alpha value of `1.0`.
    public static var blue = ColorRepresentation(0, 0, 1)

    /// The color yellow.
    ///
    /// The values for yellow are  (`1.0`, `1.0`, `0.0`) with an alpha value of `1.0`.
    public static let yellow = ColorRepresentation(1, 1, 0)

    /// The color cyan.
    ///
    /// The values for cyan are  (`0.0`, `1.0`, `1.0`) with an alpha value of `1.0`.
    public static let cyan = ColorRepresentation(0, 1, 1)

    /// The color magenta.
    ///
    /// The values for magenta are  (`1.0`, `0.0`, `1.0`) with an alpha value of `1.0`.
    public static let magenta = ColorRepresentation(1, 0, 1)

    /// The color orange.
    ///
    /// The values for orange are  (`1.0`, `0.5`, `0.0`) with an alpha value of `1.0`.
    public static let orange = ColorRepresentation(1, 0.5, 0)
}
