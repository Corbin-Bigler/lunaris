import simd
import Orbiverse

extension float4x4{
    
    static func orthographicProjection(rectangle: Rectangle, near: Float, far: Float) -> float4x4 {
        let left = rectangle.left
        let right = rectangle.right
        let top = rectangle.top
        let bottom = rectangle.bottom
        let X = float4(2 / (right - left), 0, 0, 0)
        let Y = float4(0, 2 / (top - bottom), 0, 0)
        let Z = float4(0, 0, 1 / (far - near), 0)
        let W = float4(
            (left + right) / (left - right),
            (top + bottom) / (bottom - top),
            near / (near - far),
            1)
        
        return float4x4(columns: (X, Y, Z, W))
    }
    
    static func translationMatrix(translate: SIMD3<Float>) -> matrix_float4x4 {
        return matrix_float4x4(columns: (
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(translate.x, translate.y, translate.z, 1)
        ))
    }
    static func rotationMatrixX(angle: Float) -> matrix_float4x4 {
        let c = cos(angle)
        let s = sin(angle)
        return matrix_float4x4(columns: (
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, c, s, 0),
            SIMD4<Float>(0, -s, c, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }
    
    static func rotationMatrixY(angle: Float) -> matrix_float4x4 {
        let c = cos(angle)
        let s = sin(angle)
        return matrix_float4x4(columns: (
            SIMD4<Float>(c, 0, -s, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(s, 0, c, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }
    
    static func rotationMatrixZ(angle: Float) -> matrix_float4x4 {
        let c = cos(angle)
        let s = sin(angle)
        return matrix_float4x4(columns: (
            SIMD4<Float>(c, s, 0, 0),
            SIMD4<Float>(-s, c, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }
    static func rotationMatrix(rotation: SIMD3<Float>) -> matrix_float4x4 {
        let rotationX = Self.rotationMatrixX(angle: rotation.x)
        let rotationY = Self.rotationMatrixY(angle: rotation.y)
        let rotationZ = Self.rotationMatrixZ(angle: rotation.z)
        return rotationZ * rotationY * rotationX
    }
    static func scaleMatrix(scale: SIMD3<Float>) -> matrix_float4x4 {
        return matrix_float4x4(columns: (
            SIMD4<Float>(scale.x, 0, 0, 0),
            SIMD4<Float>(0, scale.y, 0, 0),
            SIMD4<Float>(0, 0, scale.z, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }
    static func scaleMatrix(scale: Float) -> matrix_float4x4 {
        return matrix_float4x4(columns: (
            SIMD4<Float>(scale, 0, 0, 0),
            SIMD4<Float>(0, scale, 0, 0),
            SIMD4<Float>(0, 0, scale, 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }
}
