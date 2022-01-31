//
//  QuickTestView.swift
//
//
//  Created by Joseph Heck on 1/31/22.
//

import Foundation
import SceneKit
import simd
import SwiftUI

extension SCNVector3 {
    /// The simd_float3 representation that corresponds to this vector.
    var simd_float3: simd_float3 {
        simd.simd_float3(x: Float(x), y: Float(y), z: Float(z))
    }
}

func triangleNode() -> SCNNode {
    let v1 = Vector(0, 0, 0)
    let v2 = Vector(0, 1, 0)
    let v3 = Vector(1, 1, 0)

    let polygon = Triangle([v1, v2, v3])
    let tri = Mesh([polygon!])
    return SCNNode(geometry: SCNGeometry(tri))
}

func directionalFin() -> SCNNode? {
    let positions: [Vector] = [
        Vector(x: 0.05, y: 0, z: 0), // 0
        Vector(x: -0.05, y: 0, z: 0), // 1
        Vector(x: 0, y: 1, z: 0), // 2
        Vector(x: 0, y: 0, z: 0.5), // 3
    ]

    if let back = Triangle(positions[0], positions[1], positions[2]),
       let bottom = Triangle(positions[0], positions[3], positions[1]),
       let left = Triangle(positions[0], positions[2], positions[3]),
       let right = Triangle(positions[2], positions[1], positions[3])
    {
        let mesh = Mesh([back, bottom, left, right])
        // Geometry from the mesh:
        // let geo = SCNGeometry(mesh))
        
        // Bounding Box geometry from the mesh:
        // let geo = SCNGeometry(mesh.bounds)
        
        // Wireframe geometry from the mesh:
        let geo = SCNGeometry(wireframe: mesh)
        geo.materials = [SCNMaterial(.red)]

        return SCNNode(geometry: geo)
    }
    return nil
}


@available(macOS 12.0, iOS 15.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    struct QuickTestView: View {
        let scene: SCNScene
        let headingIndicator: SCNNode
        @State private var angle: String = ""
        @State private var angleValue: Float = 0
        @State private var axis: simd_float3 = .init(x: 0, y: 0, z: 0)
        var body: some View {
            VStack {
                HStack {
                    Button("X") {
                        axis = simd_float3(x: 1, y: 0, z: 0)
                    }
                    Button("Y") {
                        axis = simd_float3(x: 0, y: 1, z: 0)
                    }
                    Button("Z") {
                        axis = simd_float3(x: 0, y: 0, z: 1)
                    }
                    Button("XZ") {
                        // IMPORTANT: Normalize the axis!!! Otherwise it starts to distort as it rotates...
                        axis = simd_normalize(simd_float3(x: 1, y: 0, z: 1))
                    }
                    Text("angle: \(angleValue.formatted(.number.precision(.significantDigits(2))))")
                    TextField("radians", text: $angle)
                        .onSubmit {
                            if let someValue = Float(angle) {
                                angleValue = someValue
                                SCNTransaction.begin()
                                SCNTransaction.animationDuration = 0.4
                                headingIndicator.simdOrientation = simd_quatf(angle: angleValue, axis: axis)
                                SCNTransaction.commit()
                            }
                        }
                }
                SceneView(
                    scene: scene,
                    options: [.allowsCameraControl, .autoenablesDefaultLighting]
                ).border(Color.gray).padding()
            }
        }

        init(sceneSet: (SCNScene, SCNNode)) {
            scene = sceneSet.0
            headingIndicator = sceneSet.1
        }
    }

    static func generateExampleScene() -> (SCNScene, SCNNode) {
        let scene = SCNScene()
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        // place the camera
        cameraNode.position = SCNVector3(x: 3, y: 3, z: 3)
        cameraNode.simdLook(at: simd_float3(x: 0, y: 0, z: 0))

        let tri = directionalFin()!
        tri.geometry?.materials = [SCNMaterial(.red)]
        scene.rootNode.addChildNode(tri)

        return (scene, tri)
    }

    static var previews: some View {
        QuickTestView(sceneSet: generateExampleScene())
    }
}
