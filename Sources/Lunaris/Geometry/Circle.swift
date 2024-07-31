import Foundation

public struct Circle: Shape {
    public var position: Point
    public let radius: Float
    
    public init(position: Point, radius: Float) {
        self.position = position
        self.radius = radius
    }
    
    public func overlap(with circle: Circle) -> Vector? {
        let offset = position.offset(from: circle.position)
        let magnitude = offset.magnitude
        let rSum = (radius + circle.radius)
        if magnitude == 0 {
            return Vector.random * rSum
        }
        
        let diff = rSum - magnitude
        if diff < 0 {return nil}

        return offset.normal * diff
    }
}
