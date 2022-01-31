//
//  Mesh.swift
//
//
//  Created by Joseph Heck on 1/30/22.
//  Copyright © 2022 Joseph Heck. All rights reserved.
//
//  Portions of this code Created by Nick Lockwood on 03/07/2018.
//  Copyright © 2018 Nick Lockwood. All rights reserved.
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/Euclid
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/// A 3D surface that is represented by multiple polygons.
///
/// A mesh surface can be convex or concave, and can have zero volume (for example, a flat shape such as a square) but shouldn't contain holes or exposed back-faces.
/// The result of constructive solid geometry operations on meshes that have holes or exposed back-faces is undefined.
public struct Mesh: Hashable {
    private let storage: Storage
}

public extension Mesh {
    /// The type used as a material for a given polygon.
    typealias Material = Triangle.Material

    /// The collection of materials used for the mash.
    var materials: [Material?] { storage.materials }
    /// The collection of triangles that make up the mesh.
    var polygons: [Triangle] { storage.polygons }
    /// The bounds of the mesh.
    var bounds: Bounds { storage.bounds }

    /// The triangles of the mesh, grouped by material.
    var polygonsByMaterial: [Material?: [Triangle]] {
        polygons.groupedByMaterial()
    }

    /// The unique triangle edges in the mesh.
    var uniqueEdges: Set<LineSegment> {
        polygons.uniqueEdges
    }

    /// Indicates that the mesh is watertight.
    ///
    /// For example, the value is `true` if every edge is attached to at least 2 triangles.
    /// > Note: A mesh being watertight doesn't verify that mesh is not self-intersecting or inside-out.
    var isWatertight: Bool {
        storage.isWatertight
    }

    /// Creates a new mesh from an array of triangles.
    init(_ polygons: [Triangle]) {
        self.init(
            unchecked: polygons,
            bounds: nil,
            isConvex: false,
            isWatertight: nil
        )
    }

    /// Replaces a material with another that you provide.
    func replacing(_ old: Material?, with new: Material?) -> Mesh {
        Mesh(
            unchecked: polygons.map {
                $0.material == old ? $0.with(material: new) : $0
            },
            bounds: boundsIfSet,
            isConvex: isConvex,
            isWatertight: watertightIfSet
        )
    }

    /// Flips face direction of polygons within the mesh.
    func inverted() -> Mesh {
        Mesh(
            unchecked: polygons.inverted(),
            bounds: boundsIfSet,
            isConvex: false,
            isWatertight: watertightIfSet
        )
    }
}

internal extension Mesh {
    init(
        unchecked polygons: [Triangle],
        bounds: Bounds?,
        isConvex: Bool,
        isWatertight: Bool?
    ) {
        storage = polygons.isEmpty ? .empty : Storage(
            polygons: polygons,
            bounds: bounds,
            isConvex: isConvex,
            isWatertight: isWatertight
        )
    }

    var boundsIfSet: Bounds? { storage.boundsIfSet }
    var watertightIfSet: Bool? { storage.watertightIfSet }
    var isConvex: Bool { storage.isConvex }
}

private extension Mesh {
    final class Storage: Hashable {
        let polygons: [Triangle]
        let isConvex: Bool

        static let empty = Storage(
            polygons: [],
            bounds: .empty,
            isConvex: true,
            isWatertight: true
        )

        private(set) var materialsIfSet: [Material?]?
        var materials: [Material?] {
            if materialsIfSet == nil {
                var materials = [Material?]()
                for polygon in polygons {
                    let material = polygon.material
                    if !materials.contains(material) {
                        materials.append(material)
                    }
                }
                materialsIfSet = materials
            }
            return materialsIfSet!
        }

        private(set) var boundsIfSet: Bounds?
        var bounds: Bounds {
            if boundsIfSet == nil {
                boundsIfSet = Bounds(polygons: polygons)
            }
            return boundsIfSet!
        }

        private(set) var watertightIfSet: Bool?
        var isWatertight: Bool {
            if watertightIfSet == nil {
                watertightIfSet = polygons.areWatertight
            }
            return watertightIfSet!
        }

        static func == (lhs: Storage, rhs: Storage) -> Bool {
            lhs === rhs || lhs.polygons == rhs.polygons
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(polygons)
        }

        init(
            polygons: [Triangle],
            bounds: Bounds?,
            isConvex: Bool,
            isWatertight: Bool?
        ) {
            assert(isWatertight == nil || isWatertight == polygons.areWatertight)
            self.polygons = polygons
            boundsIfSet = polygons.isEmpty ? .empty : bounds
            self.isConvex = isConvex || polygons.isEmpty
            watertightIfSet = polygons.isEmpty ? true : isWatertight
        }
    }
}
