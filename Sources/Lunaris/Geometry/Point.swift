import Foundation

public struct Point: Codable {
    public static let zero = Point(x: 0, y: 0)
    public static let unit = Point(x: 1, y: 1)
    public static let negUnit = Point(x: -1, y: -1)

    public var x: Float
    public var y: Float
    
    public var xy: SIMD2<Float> { SIMD2<Float>(x, y) }
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    public init(_ size: CGSize) {
        self.x = Float(size.width)
        self.y = Float(size.height)
    }
    public init(_ point: CGPoint) {
        self.x = Float(point.x)
        self.y = Float(point.y)
    }
    
    public func distance(to point: Point) -> Float {
        let dx = point.x - self.x
        let dy = point.y - self.y
        return sqrt(dx * dx + dy * dy)
    }
    public func offset(from point: Point) -> Vector {
        return Vector(x: self.x - point.x, y: self.y - point.y)
    }

    public static func * (lhs: Point, rhs: Float) -> Point {
        Point(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    public static func * (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    public static func / (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    public static func / (lhs: Point, rhs: Float) -> Point {
        Point(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    public static func + (lhs: Point, rhs: Vector) -> Point {
        Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    public static func += (lhs: inout Point, rhs: Vector) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    public static func += (lhs: inout Point, rhs: Point) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    public static func - (lhs: Point, rhs: Vector) -> Point {
        Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    public static func -= (lhs: inout Point, rhs: Vector) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
    public static func -= (lhs: inout Point, rhs: Point) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

}
