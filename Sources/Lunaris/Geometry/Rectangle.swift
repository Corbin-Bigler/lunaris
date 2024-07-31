import Foundation

struct Rectangle: Shape {
    var position: Point
    let size: Vector
    
    var left: Float { position.x }
    var right: Float { position.x + size.width }
    var top: Float { position.y }
    var bottom: Float { position.x + size.height }
}
