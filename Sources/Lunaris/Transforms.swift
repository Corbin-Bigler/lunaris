//
//  Transforms.swift
//  lunaris dev
//
//  Created by Corbin Bigler on 7/21/24.
//

import Foundation

public struct Transforms {
    public static let unit = Transforms()
    
    let rotation: SIMD3<Float>
    let translation: SIMD3<Float>
    let scale: SIMD3<Float>
    
    public init(rotation: SIMD3<Float> = SIMD3<Float>(repeating: 0), translation: SIMD3<Float> = SIMD3<Float>(repeating: 0), scale: SIMD3<Float> = SIMD3<Float>(repeating: 1)) {
        self.rotation = rotation
        self.translation = translation
        self.scale = scale
    }
}
