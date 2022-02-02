//
//  ExportContentTests.swift
//  
//
//  Created by Joseph Heck on 2/2/22.
//

import MeshGenerator
import XCTest
import SceneKit
import ModelIO
import MetalKit

class ExportContentTests: XCTestCase {
    
    func testExportTetrahedronSceneKit() throws {
        let positions: [Vector] = [
            Vector(x: 0.5, y: 0, z: 0), // 0
            Vector(x: -0.5, y: 0, z: 0), // 1
            Vector(x: 0, y: 1, z: 0), // 2
            Vector(x: 0, y: 0, z: 0.5), // 3
        ]
        
        let back = Triangle(positions[0], positions[1], positions[2], material: ColorRepresentation.red)
        let bottom = Triangle(positions[0], positions[3], positions[1], material: ColorRepresentation.white)
        let left = Triangle(positions[0], positions[2], positions[3], material: ColorRepresentation.blue)
        let right = Triangle(positions[2], positions[1], positions[3], material: ColorRepresentation.green)
        let mesh = Mesh([back, bottom, left, right])
        
        // Geometry from the mesh:
        let geo = SCNGeometry(mesh)
        geo.materials = [SCNMaterial(ColorRepresentation.red)]
        let scene = SCNScene()
        scene.rootNode.addChildNode(SCNNode(geometry: geo))
        
        let path = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)[0]
                                                 .appendingPathComponent("tetrahedron.usdz")
            
        scene.write(to: path, options: nil, delegate: nil, progressHandler: nil)

        XCTAssertNotNil(geo)
        
    }

    func testExportTetrahedronModelIO() throws {
        let positions: [Vector] = [
            Vector(x: 0.5, y: 0, z: 0), // 0
            Vector(x: -0.5, y: 0, z: 0), // 1
            Vector(x: 0, y: 1, z: 0), // 2
            Vector(x: 0, y: 0, z: 0.5), // 3
        ]
        
        let back = Triangle(positions[0], positions[1], positions[2], material: ColorRepresentation.red)
        let bottom = Triangle(positions[0], positions[3], positions[1], material: ColorRepresentation.white)
        let left = Triangle(positions[0], positions[2], positions[3], material: ColorRepresentation.blue)
        let right = Triangle(positions[2], positions[1], positions[3], material: ColorRepresentation.green)
        let mesh = Mesh([back, bottom, left, right])
        // Geometry from the mesh:
        let geo = SCNGeometry(mesh)
        
        
        // IMPORT METALKIT - ...
        // MTKMesh <- MTKMeshBuffer <- MTKMeshBufferAllocator
        if let device = MTLCreateSystemDefaultDevice() {
            let mtlAllocator = MTKMeshBufferAllocator(device: device)
            XCTAssertNotNil(mtlAllocator)
        }

        /*
         Another variation on the theme: from https://stackoverflow.com/questions/46804603/programmatic-generation-of-mdlmesh-objects-using-initwithvertexbuffers
         
         static const float equilateralTriangleVertexData[] =
         {
               0.000000,  0.577350,  0.0,
              -0.500000, -0.288675,  0.0,
               0.500000, -0.288675,  0.0,
         };

         static const vector_float3 equilateralTriangleVertexNormalsData[] =
         {
             { 0.0,  0.0,  1.0 },
             { 0.0,  0.0,  1.0 },
             { 0.0,  0.0,  1.0 },
         };

         static const vector_float2 equilateralTriangleVertexTexData[] =
         {
             { 0.50, 1.00 },
             { 0.00, 0.00 },
             { 1.00, 0.00 },
         };

         int numVertices = 3;

         int lenBufferForVertices_position          = sizeof(equilateralTriangleVertexData);
         int lenBufferForVertices_normal            = numVertices * sizeof(vector_float3);
         int lenBufferForVertices_textureCoordinate = numVertices * sizeof(vector_float2);

         MTKMeshBuffer *mtkMeshBufferForVertices_position          = (MTKMeshBuffer *)[metalAllocator newBuffer:lenBufferForVertices_position          type:MDLMeshBufferTypeVertex];
         MTKMeshBuffer *mtkMeshBufferForVertices_normal            = (MTKMeshBuffer *)[metalAllocator newBuffer:lenBufferForVertices_normal            type:MDLMeshBufferTypeVertex];
         MTKMeshBuffer *mtkMeshBufferForVertices_textureCoordinate = (MTKMeshBuffer *)[metalAllocator newBuffer:lenBufferForVertices_textureCoordinate type:MDLMeshBufferTypeVertex];

         // Now fill the Vertex buffers with vertices.

         NSData *nsData_position          = [NSData dataWithBytes:equilateralTriangleVertexData        length:lenBufferForVertices_position];
         NSData *nsData_normal            = [NSData dataWithBytes:equilateralTriangleVertexNormalsData length:lenBufferForVertices_normal];
         NSData *nsData_textureCoordinate = [NSData dataWithBytes:equilateralTriangleVertexTexData     length:lenBufferForVertices_textureCoordinate];

         [mtkMeshBufferForVertices_position          fillData:nsData_position          offset:0];
         [mtkMeshBufferForVertices_normal            fillData:nsData_normal            offset:0];
         [mtkMeshBufferForVertices_textureCoordinate fillData:nsData_textureCoordinate offset:0];

         NSArray <id<MDLMeshBuffer>> *arrayOfMeshBuffers = [NSArray arrayWithObjects:mtkMeshBufferForVertices_position, mtkMeshBufferForVertices_normal, mtkMeshBufferForVertices_textureCoordinate, nil];

         static uint16_t indices[] =
         {
             0,  1,  2,
         };

         int numIndices = 3;

         int lenBufferForIndices = numIndices * sizeof(uint16_t);
         MTKMeshBuffer *mtkMeshBufferForIndices = (MTKMeshBuffer *)[metalAllocator newBuffer:lenBufferForIndices type:MDLMeshBufferTypeIndex];

         NSData *nsData_indices = [NSData dataWithBytes:indices length:lenBufferForIndices];
         [mtkMeshBufferForIndices fillData:nsData_indices offset:0];

         MDLScatteringFunction *scatteringFunction = [MDLPhysicallyPlausibleScatteringFunction new];
         MDLMaterial *material = [[MDLMaterial alloc] initWithName:@"plausibleMaterial" scatteringFunction:scatteringFunction];

         // Not allowed to create an MTKSubmesh directly, so feed an MDLSubmesh to an MDLMesh, and then use that to load an MTKMesh, which makes the MTKSubmesh from it.
         MDLSubmesh *submesh = [[MDLSubmesh alloc] initWithName:@"summess" // Hackspeke for @"submesh"
                                                    indexBuffer:mtkMeshBufferForIndices
                                                     indexCount:numIndices
                                                      indexType:MDLIndexBitDepthUInt16
                                                   geometryType:MDLGeometryTypeTriangles
                                                       material:material];

         NSArray <MDLSubmesh *> *arrayOfSubmeshes = [NSArray arrayWithObjects:submesh, nil];

         MDLMesh *mdlMesh = [[MDLMesh alloc] initWithVertexBuffers:arrayOfMeshBuffers
                                                       vertexCount:numVertices
                                                        descriptor:mdlVertexDescriptor
                                                         submeshes:arrayOfSubmeshes];
         */
        let scene = SCNScene()
        let node = SCNNode(geometry: geo)
        
        scene.rootNode.addChildNode(node)
        
        let path = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)[0]
                                                 .appendingPathComponent("tetrahedron.usdz")
            
        scene.write(to: path, options: nil, delegate: nil, progressHandler: nil)

        XCTAssertNotNil(geo)
        
    }

}
