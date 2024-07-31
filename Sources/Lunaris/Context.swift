import MetalKit

extension Lunaris {
    public struct Context {
        static var depthState: MTLDepthStencilState = {
            let depthDescriptor = MTLDepthStencilDescriptor()
            depthDescriptor.depthCompareFunction = .less
            depthDescriptor.isDepthWriteEnabled = true
            return Lunaris.device.makeDepthStencilState(descriptor: depthDescriptor)!
        }()
        static var noDepthState: MTLDepthStencilState = {
            let depthDescriptor = MTLDepthStencilDescriptor()
            depthDescriptor.isDepthWriteEnabled = false
            return Lunaris.device.makeDepthStencilState(descriptor: depthDescriptor)!
        }()
        
        let enableDepthTesting: Bool
        let mdlVertexDescriptor: MDLVertexDescriptor
        let vertexBuffers: [VertexBuffer]
        let pipelineState: MTLRenderPipelineState
        let wireframe: Bool
        let cullMode: MTLCullMode

        init(
            enableDepthTesting: Bool,
            enableBlending: Bool,
            wireframe: Bool,
            cullMode: MTLCullMode,
            fragmentFunction: String,
            vertexFunction: String,
            vertexBuffers: [VertexBuffer]
        ) {
            self.enableDepthTesting = enableDepthTesting
            self.vertexBuffers = vertexBuffers
            self.wireframe = wireframe
            self.cullMode = cullMode
            
            self.mdlVertexDescriptor = MDLVertexDescriptor()
            outer: for (index, buffer) in vertexBuffers.enumerated() {
                let attributeName: String
                switch(buffer) {
                case .position: attributeName = MDLVertexAttributePosition
                case .normal: attributeName = MDLVertexAttributeNormal
                case .uv: attributeName = MDLVertexAttributeTextureCoordinate
                default: break outer
                }
                let format: MDLVertexFormat
                switch(buffer) {
                case .position: format = .float4
                case .normal: format = .float3
                case .uv: format = .float2
                default: break outer
                }
                let stride: Int
                switch(buffer) {
                case .position: stride = MemoryLayout<SIMD4<Float>>.stride
                case .normal: stride = MemoryLayout<SIMD3<Float>>.stride
                case .uv: stride = MemoryLayout<SIMD2<Float>>.stride
                default: break outer
                }

                mdlVertexDescriptor.attributes[index] = MDLVertexAttribute(
                    name: attributeName,
                    format: format,
                    offset: 0,
                    bufferIndex: index
                )
                mdlVertexDescriptor.layouts[index] = MDLVertexBufferLayout(stride: stride)
            }
            let mtkVertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlVertexDescriptor)!
            
            let vertexFunction = Lunaris.library.makeFunction(name: vertexFunction)
            let fragmentFunction = Lunaris.library.makeFunction(name: fragmentFunction)
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.vertexDescriptor = mtkVertexDescriptor
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            if(enableBlending) {
                pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
                pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
                pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
                pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
                pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
                pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
                pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            }
            
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
            
            self.pipelineState = try! Lunaris.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
    }
}
