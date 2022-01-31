//
//  MeshGenerator+AppKit.swift
//
//
//  Created by Joseph Heck on 1/29/22.
//  Copyright © 2022 Joseph Heck. All rights reserved.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

    import AppKit

    public extension NSColor {
        convenience init(_ color: ColorRepresentation) {
            self.init(
                red: CGFloat(color.red),
                green: CGFloat(color.green),
                blue: CGFloat(color.blue),
                alpha: CGFloat(color.alpha)
            )
        }
    }

#endif
