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
/// ## Topics
///
/// ### Creating a Color Representation
///
/// - ``init(r:g:b:)``
/// - ``init(red:green:blue:alpha:)``
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
    public init(r: Double, g: Double, b: Double) {
        precondition(r <= 1.0 && g <= 1.0 && b <= 1.0)
        red = r
        green = g
        blue = b
        alpha = 1.0
    }

    /// Creates a new color representation using the red, green, blue and alpha values you provide.
    /// - Parameters:
    ///   - red: The red value, from 0 to 1.0.
    ///   - green: The green value, from 0 to 1.0.
    ///   - blue: The blue value, from 0 to 1.0.
    ///   - alpha: The alpha value, from 0 to 1.0.
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        precondition(red <= 1.0 && green <= 1.0 && blue <= 1.0 && alpha <= 1.0)
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    static var black: ColorRepresentation {
        return ColorRepresentation(r: 0, g: 0, b: 0)
    }
}
