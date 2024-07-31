import Foundation

public struct Vector {
    public static let zero = Vector(x: 0, y: 0)
    public static let unit = Vector(x: 1, y: 1)
    public static var random: Vector {
        Vector(x: Float.random(in: 0...1), y: Float.random(in: 0...1)).normal
    }

    public var x: Float
    public var y: Float
    
    public var point: Point { Point(x: x, y: y) }
    public var xy: SIMD2<Float> { SIMD2<Float>(x, y) }
    public var width: Float { x }
    public var height: Float { y }
    public var max: Float { Swift.max(x, y) }
    public var min: Float { Swift.min(x, y) }
    public var magnitude: Float { sqrt(x * x + y * y) }
    public var angle: Angle { Angle(radians: atan2(y, x)) }
    public var normal: Vector {
        let length = magnitude
        guard length != 0 else { return Vector(x: 0, y: 0) }
        return Vector(x: x / length, y: y / length)
    }
    
    public init(angle: Angle) {
        let radians = angle.radians
        self.x = cos(radians)
        self.y = sin(radians)
    }
    public init(_ value: Float) {
        self.x = value
        self.y = value
    }
    public init(y: Float) {
        self.x = 0
        self.y = y
    }
    public init(x: Float) {
        self.x = x
        self.y = 0
    }
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    public init(_ size: CGSize) {
        self.x = Float(size.width)
        self.y = Float(size.height)
    }
    
    public static func * (lhs: Vector, rhs: Vector) -> Vector {
        Vector(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    public static func * (lhs: Vector, rhs: Float) -> Vector {
        Vector(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    public static func / (lhs: Vector, rhs: Float) -> Vector {
        Vector(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    public static func *= (lhs: inout Vector, rhs: Float) {
        lhs.x *= rhs
        lhs.y *= rhs
    }
    public static func *= (lhs: inout Vector, rhs: Vector) {
        lhs.x *= rhs.x
        lhs.y *= rhs.y
    }
    public static prefix func - (vector: Vector) -> Vector {
        Vector(x: -vector.x, y: -vector.y)
    }
}
