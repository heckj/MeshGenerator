//
//  MeshGenerator+ModelIO.swift
//
//
//  Created by Joseph Heck on 2/2/22.
//

#if canImport(ModelIO)
    import MetalKit
    import ModelIO
    import SceneKit
    //import MetalKit
    import SceneKit.ModelIO // <-- required to get the initialization of MDLMesh from an SCNGeometry instance...
     
    class WhyNotWorking {
        init() {
            let box = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 0.0)
            let mesh = MDLMesh(scnGeometry: box, bufferAllocator: nil)
        }
    }

    fileprivate extension Data {
        mutating func append(_ int: UInt32) {
            var int = int
            withUnsafeMutablePointer(to: &int) { pointer in
                append(UnsafeBufferPointer(start: pointer, count: 1))
            }
        }

        mutating func append(_ double: Double) {
            var float = Float(double)
            withUnsafeMutablePointer(to: &float) { pointer in
                append(UnsafeBufferPointer(start: pointer, count: 1))
            }
        }

        mutating func append(_ vector: Vector) {
            append(vector.x)
            append(vector.y)
            append(vector.z)
        }
    }

    // IMPORT METALKIT - ...
    // MTKMesh <- MTKMeshBuffer <- MTKMeshBufferAllocator
    func foo(x: Mesh) {
//    guard let device = MTLCreateSystemDefaultDevice() else {
//        return
//    }
//    let mtlAllocator = MTKMeshBufferAllocator(device: device)

        var vertexData = Data()
//    var materials = [SCNMaterial]()
        var indicesByVertex = [Vertex: UInt32]()
//    let materialLookup = materialLookup ?? defaultMaterialLookup
        for (_, polygons) in x.polygonsByMaterial {
            // for (material, polygons) in x.polygonsByMaterial {
            var indexData = Data()
            func addVertex(_ vertex: Vertex) {
                if let index = indicesByVertex[vertex] {
                    indexData.append(index)
                    return
                }
                let index = UInt32(indicesByVertex.count)
                indicesByVertex[vertex] = index
                indexData.append(index)

                vertexData.append(vertex.position)
                vertexData.append(vertex.normal)
                vertexData.append(vertex.tex.u)
                vertexData.append(vertex.tex.v)
            }
            // materials.append(materialLookup(material) ?? SCNMaterial())
            for polygon in polygons {
                polygon.vertices.forEach(addVertex)
            }
        }

        // get number of vertices
        // create a new buffer of that size

        // Doing this with MDLMesh directly means using a lot of addAttribute and knowing the specific strings (or constants):
        // - MDLVertexAttributePosition: String
        // - MDLVertexAttributeNormal: String
        // - MDLVertexAttributeTextureCoordinate: String

        // So it's probably easier to rely on MetalKit and generate the buffers into that, and then extract that back down into
        // ModelIO for export. Which is actually pretty fucked up for an API. That said, ModelIO was released with iOS 9, and hasn't
        // been notably updated beyond iOS 11(macOS 10.13) other than supporting fixes through ~iOS 14. So that's 7 years old, and
        // effectively on life support.

//    /**
//     @method addAttributeWithName:format:type:data:stride
//     @abstract Create a new vertex attribute including an associated buffer with
//               a copy of the supplied data, and update the vertex descriptor accordingly
//     @param name The name the attribute can be found by
//     @param format Format of the data, such as MDLVertexFormatFloat3
//     @param type The usage of the attribute, such as MDLVertexAttributePosition
//     @param data Object containing the data to be used in the new vertex buffer
//     @param stride The increment in bytes from the start of one data entry to
//            the next.
//     */
//    open func addAttribute(withName name: String, format: MDLVertexFormat, type: String, data: Data, stride: Int)

//    let mtlBuffer = mtlAllocator.newBuffer(with: vertexData, type: .vertex)
//    let xx = mtlAllocator.newBuffer(<#T##length: Int##Int#>, type: <#T##MDLMeshBufferType#>)
//
//    let mdlMeshBuffer = MDLMeshBufferData(type: ., data: <#T##Data?#>)
//    let mdlMesh = MDLMesh(vertexBuffers: <#T##[MDLMeshBuffer]#>, vertexCount: <#T##Int#>, descriptor: <#T##MDLVertexDescriptor#>, submeshes: <#T##[MDLSubmesh]#>)
//    let posMesh = MDLSubmesh(indexBuffer: <#T##MDLMeshBuffer#>, indexCount: <#T##Int#>, indexType: MDLIndexBitDepth.uInt32, geometryType: MDLGeometryType.triangles, material: nil)
//
//    MDLSubmesh *submesh = [[MDLSubmesh alloc] initWithName:@"summess" // Hackspeke for @"submesh"
//                                               indexBuffer:mtkMeshBufferForIndices
//                                                indexCount:numIndices
//                                                 indexType:MDLIndexBitDepthUInt16
//                                              geometryType:MDLGeometryTypeTriangles
//                                                  material:material];

        // MTKMeshBuffer *mtkMeshBufferForVertices_position          = (MTKMeshBuffer *)[metalAllocator newBuffer:lenBufferForVertices_position          type:MDLMeshBufferTypeVertex];
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

     // use MetalKit to create 3 buffers (type: .vertex)

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

     // The make an array of those buffers - position, normal, then texture

     NSArray <id<MDLMeshBuffer>> *arrayOfMeshBuffers = [NSArray arrayWithObjects:mtkMeshBufferForVertices_position, mtkMeshBufferForVertices_normal, mtkMeshBufferForVertices_textureCoordinate, nil];

     static uint16_t indices[] =
     {
         0,  1,  2,
     };

     int numIndices = 3;

     int lenBufferForIndices = numIndices * sizeof(uint16_t);

     // make ANOTHER MetalKit buffer - but this time of type .index

     MTKMeshBuffer *mtkMeshBufferForIndices = (MTKMeshBuffer *)[metalAllocator newBuffer:lenBufferForIndices type:MDLMeshBufferTypeIndex];

     NSData *nsData_indices = [NSData dataWithBytes:indices length:lenBufferForIndices];
     [mtkMeshBufferForIndices fillData:nsData_indices offset:0];

     // and make a basic MDLMaterial to apply to each of the vertices

     MDLScatteringFunction *scatteringFunction = [MDLPhysicallyPlausibleScatteringFunction new];
     MDLMaterial *material = [[MDLMaterial alloc] initWithName:@"plausibleMaterial" scatteringFunction:scatteringFunction];

     // Not allowed to create an MTKSubmesh directly, so feed an MDLSubmesh to an MDLMesh, and then use that to load an MTKMesh, which makes the MTKSubmesh from it.
     MDLSubmesh *submesh = [[MDLSubmesh alloc] initWithName:@"summess" // Hackspeke for @"submesh"
                                                indexBuffer:mtkMeshBufferForIndices
                                                 indexCount:numIndices
                                                  indexType:MDLIndexBitDepthUInt16
                                               geometryType:MDLGeometryTypeTriangles
                                                   material:material];

     // array of 1 submesh

     NSArray <MDLSubmesh *> *arrayOfSubmeshes = [NSArray arrayWithObjects:submesh, nil];

     // and finally, create the MDLMesh

     MDLMesh *mdlMesh = [[MDLMesh alloc] initWithVertexBuffers:arrayOfMeshBuffers
                                                   vertexCount:numVertices
                                                    descriptor:mdlVertexDescriptor
                                                     submeshes:arrayOfSubmeshes];
     */
#endif
