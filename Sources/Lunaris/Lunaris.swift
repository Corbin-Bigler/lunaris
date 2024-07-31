import MetalKit
import SwiftUI

public class Lunaris: NSObject, MTKViewDelegate {
    static let initialModelBufferSize = 1000
    static var device: MTLDevice!
    static var library: MTLLibrary!
    static let textureLoader = MTKTextureLoader(device: device)
    static var modelBufferPool: [MTLBuffer] = []
    static var usedModelBuffers = 0
    static func getModelBuffer(transforms: Transforms) -> MTLBuffer {
        let translation = float4x4.translationMatrix(translate: transforms.translation)
        let rotation = float4x4.rotationMatrix(rotation: transforms.rotation)
        let scale = float4x4.scaleMatrix(scale: transforms.scale)
        
        let modelMatrix = translation * rotation * scale
        if modelBufferPool.count - 1 < usedModelBuffers {
            modelBufferPool.append(Self.device.makeBuffer(length: MemoryLayout<ModelTransform>.stride)!)
        }
        var modelTransform = ModelTransform(modelMatrix: modelMatrix, normalMatrix: matrix_identity_float3x3)

        let buffer = modelBufferPool[usedModelBuffers]
        memcpy(buffer.contents(), &modelTransform, MemoryLayout<ModelTransform>.stride)
        usedModelBuffers += 1
        return buffer
    }

    var commandQueue: MTLCommandQueue!
    var draw: (Renderer) -> () = {_ in }
    var viewSize = Vector.unit
    let uniformsBuffer: MTLBuffer
    
    public override init() {
        Self.device = MTLCreateSystemDefaultDevice()!
        Self.library = Self.device.makeDefaultLibrary()!
        
        self.uniformsBuffer = Self.device.makeBuffer(length: MemoryLayout<Uniforms>.stride)!
        self.commandQueue = Self.device.makeCommandQueue()!
        
        if Self.modelBufferPool.isEmpty {
            for _ in 0..<Self.initialModelBufferSize {
                Self.modelBufferPool.append(Self.device.makeBuffer(length: MemoryLayout<ModelTransform>.stride)!)
            }
        }
    }
    
    public func onDraw(draw: @escaping (Renderer) -> ()) {
        self.draw = draw
    }
    public func createContext(
        enableDepthTesting: Bool = true,
        enableBlending: Bool = true,
        wireframe: Bool = false,
        cullmode: MTLCullMode = .back,
        fragmentFunction: String,
        vertexFunction: String,
        vertexBuffers: [VertexBuffer]
    ) -> Context {
        Context(
            enableDepthTesting: enableDepthTesting,
            enableBlending: enableBlending,
            wireframe: wireframe,
            cullMode: cullmode,
            fragmentFunction: fragmentFunction,
            vertexFunction: vertexFunction,
            vertexBuffers: vertexBuffers
        )
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    public func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
                let passDescriptor = view.currentRenderPassDescriptor
        else { return }
        
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].storeAction = .store
        passDescriptor.depthAttachment.loadAction = .clear
        passDescriptor.depthAttachment.storeAction = .store
        passDescriptor.depthAttachment.clearDepth = 1

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
                let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor)
        else { return }

        let renderer = Renderer(renderEncoder: renderEncoder, lunaris: self, viewSize: Vector(view.drawableSize))
        draw(renderer)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        Self.usedModelBuffers = 0
    }
}

extension Lunaris {
    public func createUsdzModel(name: String, context: Context) -> Model {
        let url = Bundle.main.url(forResource: name, withExtension: "usdz")!

        let allocator = MTKMeshBufferAllocator(device: Lunaris.device)
        let asset = MDLAsset(
            url: url,
            vertexDescriptor: context.mdlVertexDescriptor,
            bufferAllocator: allocator
        )
        asset.loadTextures()
                
        var loadedMeshes: [Mesh] = []
        let mdlMeshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh] ?? []
        
        for mdlMesh in mdlMeshes {
            let mtkMesh = try! MTKMesh(mesh: mdlMesh, device: Lunaris.device)
            let mesh = Mesh(name: name, mdlMesh: mdlMesh, mtkMesh: mtkMesh)
            loadedMeshes.append(mesh)
        }
        
        return Model(meshes: loadedMeshes)
    }
    
    func createQuadModel(baseColor: MTLTexture, context: Context) -> Model {
        let positionData: [SIMD4<Float>] = [
            SIMD4<Float>(0, 0, 0, 1),
            SIMD4<Float>(0, 1, 0, 1),
            SIMD4<Float>(1, 0, 0, 1),
            SIMD4<Float>(1, 1, 0, 1)
        ]
            
        let normalData = [
            SIMD3<Float>(0, 0, 1),
            SIMD3<Float>(0, 0, 1),
            SIMD3<Float>(0, 0, 1),
            SIMD3<Float>(0, 0, 1)
        ]
        
        let uvData: [SIMD2<Float>] = [
            SIMD2<Float>(0, 1),
            SIMD2<Float>(0, 0),
            SIMD2<Float>(1, 1),
            SIMD2<Float>(1, 0)
        ]

        let quadIndices: [UInt16] = [
            0, 2, 1,
            2, 3, 1
        ]

        var vertexBuffers: [MTLBuffer] = []
        for buffer in context.vertexBuffers {
            switch buffer {
            case .position:
                let positionBuffer = Lunaris.device.makeBuffer(
                    bytes: positionData,
                    length: positionData.count * MemoryLayout<SIMD4<Float>>.stride
                )!
                vertexBuffers.append(positionBuffer)
            case .normal:
                let normalBuffer = Lunaris.device.makeBuffer(
                    bytes: normalData,
                    length: normalData.count * MemoryLayout<SIMD3<Float>>.stride
                )!
                vertexBuffers.append(normalBuffer)
            case .uv:
                let uvBuffer = Lunaris.device.makeBuffer(
                    bytes: uvData,
                    length: uvData.count * MemoryLayout<SIMD2<Float>>.stride
                )!
                vertexBuffers.append(uvBuffer)
            default: break
            }
        }
        
        let indexBuffer = Lunaris.device.makeBuffer(
            bytes: quadIndices,
            length: quadIndices.count * MemoryLayout<UInt16>.stride
        )!

        let submesh = Submesh(
            indexCount: quadIndices.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0,
            baseColor: baseColor
        )
        
        let mesh = Mesh(vertexBuffers: vertexBuffers, submeshes: [submesh])
        return Model(meshes: [mesh])
    }

    public func createQuadModel(name: String, context: Context) -> Model {
        let texture = try! Lunaris.textureLoader.newTexture(name: name, scaleFactor: 1.0, bundle: Bundle.main)
        return createQuadModel(baseColor: texture, context: context)
    }
    public func createQuadModel(color: Color, context: Context) -> Model {
        return createQuadModel(baseColor: color.toMtlTexture(device: Lunaris.device), context: context)
    }

    func createCircleModel(baseColor: MTLTexture, segments: Int, context: Context) -> Model {
        struct Vertex {
            let position: SIMD4<Float>
            let normal: SIMD3<Float>
        }
        
        // Generate circle vertices
        var positionData = [SIMD4<Float>]()
        var normalData = [SIMD3<Float>]()
        var uvData = [SIMD2<Float>]()
        var circleIndices = [UInt16]()
        
        // Center vertex
        positionData.append(SIMD4<Float>(0, 0, 0, 1))
        normalData.append(SIMD3<Float>(0, 0, 1))
        uvData.append(SIMD2<Float>(0.5, 0.5))
        
        let angleIncrement = 2.0 * Float.pi / Float(segments)
        
        for i in 0...segments {
            let angle = Float(i) * angleIncrement
            let x = cos(angle)
            let y = sin(angle)
            positionData.append(SIMD4<Float>(x, y, 0, 1))
            normalData.append(SIMD3<Float>(0, 0, 1))
            uvData.append(SIMD2<Float>((x + 1) / 2, (y + 1) / 2))
        }
        
        for i in 1...segments {
            circleIndices.append(UInt16(0))
            circleIndices.append(UInt16(i))
            circleIndices.append(UInt16(i + 1))
        }
        
        var vertexBuffers: [MTLBuffer] = []
        for buffer in context.vertexBuffers {
            switch buffer {
            case .position:
                let positionBuffer = Lunaris.device.makeBuffer(
                    bytes: positionData,
                    length: positionData.count * MemoryLayout<SIMD4<Float>>.stride
                )!
                vertexBuffers.append(positionBuffer)
            case .normal:
                let normalBuffer = Lunaris.device.makeBuffer(
                    bytes: normalData,
                    length: normalData.count * MemoryLayout<SIMD3<Float>>.stride
                )!
                vertexBuffers.append(normalBuffer)
            case .uv:
                let uvBuffer = Lunaris.device.makeBuffer(
                    bytes: uvData,
                    length: uvData.count * MemoryLayout<SIMD2<Float>>.stride
                )!
                vertexBuffers.append(uvBuffer)
            default: break
            }
        }
        
        let indexBuffer = Lunaris.device.makeBuffer(
            bytes: circleIndices,
            length: circleIndices.count * MemoryLayout<UInt16>.stride
        )!

        let submesh = Submesh(
            indexCount: circleIndices.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0,
            baseColor: baseColor
        )
        
        let mesh = Mesh(vertexBuffers: vertexBuffers, submeshes: [submesh])
        return Model(meshes: [mesh])
    }
    
    public func createCircleModel(name: String, segments: Int, context: Context) -> Model {
        let texture = try! Lunaris.textureLoader.newTexture(name: name, scaleFactor: 1.0, bundle: Bundle.main)
        return createCircleModel(baseColor: texture, segments: segments, context: context)
    }
    
    public func createCircleModel(color: Color, segments: Int, context: Context) -> Model {
        return createCircleModel(baseColor: color.toMtlTexture(device: Lunaris.device), segments: segments, context: context)
    }

}
