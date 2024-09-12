import MetalKit
import Orbiverse

public class Renderer {
    
    let renderEncoder: MTLRenderCommandEncoder
    let lunaris: Lunaris
    public let viewSize: Vector
    public var aspect: Float { viewSize.max / viewSize.min }
    var context: Lunaris.Context!
    init(renderEncoder: MTLRenderCommandEncoder, lunaris: Lunaris, viewSize: Vector) {
        self.renderEncoder = renderEncoder
        self.lunaris = lunaris
        self.viewSize = viewSize
    }
    
    public func setContext(context: Lunaris.Context) {
        self.context = context
        self.renderEncoder.setRenderPipelineState(context.pipelineState)
        if(context.enableDepthTesting) {
            renderEncoder.setDepthStencilState(Lunaris.Context.depthState)
        } else {
            renderEncoder.setDepthStencilState(Lunaris.Context.noDepthState)
        }
        renderEncoder.setCullMode(context.cullMode)
        if context.wireframe { renderEncoder.setTriangleFillMode(.lines) }
        else { renderEncoder.setTriangleFillMode(.fill) }
    }
    
    public func setCamera(variant: ProjectionVariant, rotation: Angle, offset: Vector, scale: Float) {
        guard let uniformsIndex = context.vertexBuffers.firstIndex(of: .uniforms) else { return }
                
        let viewRectSize: Vector
        if viewSize.width > viewSize.height { viewRectSize = Vector(x: scale * aspect, y: scale)}
        else { viewRectSize = Vector(x: scale, y: scale * aspect) }
        
        let viewRect = Rectangle(position: Point.zero, size: viewRectSize)
        let projectionMatrix = float4x4.orthographicProjection(rectangle: viewRect, near: scale * 10, far: -scale * 10)
        
        let rotation = matrix_float4x4.rotationMatrix(rotation: simd_float3(rotation.radians, 0, 0))
        let translation = matrix_float4x4.translationMatrix(translate: simd_float3(-offset.x, -offset.y, scale * 5))

        let viewMatrix = rotation * translation
        
        var uniforms = Uniforms(viewMatrix: viewMatrix, projectionMatrix: projectionMatrix)
        memcpy(lunaris.uniformsBuffer.contents(), &uniforms, MemoryLayout<Uniforms>.stride)
        renderEncoder.setVertexBuffer(lunaris.uniformsBuffer, offset: 0, index: uniformsIndex)
    }
    
    public func setFragmentBytes<T>(index: Int, data: T) {
        let length = MemoryLayout<T>.stride
        var data = data
        renderEncoder.setFragmentBytes(&data, length: length, index: index)
    }
    
    public func draw(model: Model, transforms: Transforms) {
        if let modelTransformIndex = context.vertexBuffers.firstIndex(of: .modelTransforms) {
            renderEncoder.setVertexBuffer(Lunaris.getModelBuffer(transforms: transforms), offset: 0, index: modelTransformIndex)
        }

        for mesh in model.meshes {
            for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
                renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: index)
            }
            
            for submesh in mesh.submeshes {
                renderEncoder.setFragmentTexture(submesh.baseColor, index: 0)
                renderEncoder.drawIndexedPrimitives(
                  type: .triangle,
                  indexCount: submesh.indexCount,
                  indexType: submesh.indexType,
                  indexBuffer: submesh.indexBuffer,
                  indexBufferOffset: submesh.indexBufferOffset
                )
            }
        }
    }
    
}
