//
//  File.swift
//  
//
//  Created by Corbin Bigler on 7/22/24.
//

import MetalKit

public struct Color {
    public static let blue = Color(r: 0, g: 0, b: 1, a: 1)
    public static let black = Color(r: 0, g: 0, b: 0, a: 1)
    public static let white = Color(r: 1, g: 1, b: 1, a: 1)
    public static let red = Color(r: 1, g: 0, b: 0, a: 1)

    public let red: Float
    public let green: Float
    public let blue: Float
    public let alpha: Float
    
    public var rgb: SIMD3<Float> {
        simd_float3(red, green, blue)
    }
    public var mtlClearColor: MTLClearColor {
        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
    }
    
    func toMtlTexture(device: MTLDevice) -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.width = 1
        textureDescriptor.height = 1
        textureDescriptor.usage = .shaderRead
        
        let linearColor = rgb
        let gammaCorrection = SIMD3<Float>(repeating: 1.0 / 2.2)
        let sRGBColor = SIMD3<Float>(pow(linearColor.x, gammaCorrection.x), pow(linearColor.y, gammaCorrection.y), pow(linearColor.z, gammaCorrection.z))
        let colorData: [UInt8] = [
            UInt8(sRGBColor.z * 255),
            UInt8(sRGBColor.y * 255),
            UInt8(sRGBColor.x * 255),
            UInt8(alpha * 255)
        ]
        let region = MTLRegionMake2D(0, 0, 1, 1)
        
        let texture = device.makeTexture(descriptor: textureDescriptor)!
        texture.replace(region: region, mipmapLevel: 0, withBytes: colorData, bytesPerRow: 4)

        return texture
    }
    
    public init(hex: UInt32) {
        let red = Float((hex >> 24) & 0xFF) / 255.0
        let green = Float((hex >> 16) & 0xFF) / 255.0
        let blue = Float((hex >> 8) & 0xFF) / 255.0
        let alpha = Float(hex & 0xFF) / 255.0
        
        self.init(r: red, g: green, b: blue, a: alpha)
    }
    public init(r: Float, g: Float, b: Float, a: Float) {
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
    }
    public init(rgb: SIMD3<Float>) {
        self.init(r: rgb.x, g: rgb.y, b: rgb.z, a: 1)
    }
}
