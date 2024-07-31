//
//  File.swift
//  
//
//  Created by Corbin Bigler on 7/21/24.
//

import MetalKit

struct Vertex {
    let position: SIMD4<Float>
    let normal: SIMD3<Float>
}

struct ModelTransform {
    let modelMatrix: float4x4
    let normalMatrix: float3x3
}

struct Uniforms {
    let viewMatrix: float4x4
    let projectionMatrix: float4x4
}

enum TextureIndices: Int {
    case baseColor = 0
}

enum Attributes: Int {
    case position = 0
    case normal = 1
    case uv = 2
}
