import MetalKit
import SwiftUI

public struct Submesh {
    let indexCount: Int
    let indexType: MTLIndexType
    let indexBuffer: MTLBuffer
    let indexBufferOffset: Int
    var baseColor: MTLTexture
    
    init(indexCount: Int, indexType: MTLIndexType, indexBuffer: MTLBuffer, indexBufferOffset: Int, baseColor: MTLTexture) {
        self.indexCount = indexCount
        self.indexType = indexType
        self.indexBuffer = indexBuffer
        self.indexBufferOffset = indexBufferOffset
        self.baseColor = baseColor
    }
    init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
        indexCount = mtkSubmesh.indexCount
        indexType = mtkSubmesh.indexType
        indexBuffer = mtkSubmesh.indexBuffer.buffer
        indexBufferOffset = mtkSubmesh.indexBuffer.offset
        
        let baseColor: MTLTexture
        
        if let mdlTexture = mdlSubmesh.material?.property(with: .baseColor)?.textureSamplerValue?.texture {
            baseColor = try! Lunaris.textureLoader.newTexture(texture: mdlTexture, options: nil)
        } else {
            let color = Color(rgb: mdlSubmesh.material?.property(with: .baseColor)?.float3Value ?? SIMD3<Float>(0,0,0))
            baseColor = color.toMtlTexture(device: Lunaris.device)
        }
        
        self.baseColor = baseColor
    }
}
