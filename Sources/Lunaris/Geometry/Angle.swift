import Foundation

public struct Angle {
    public static let zero = Angle(degrees: 0)
    public static let right = Angle(degrees: 90)
    public static let straight = Angle(degrees: 180)

    public var degrees: Float
    public var radians: Float {degrees * .pi / 180.0}
    
    public init(degrees: Float) {
        self.degrees = degrees
    }
    public init(radians: Float) {
        self.degrees = radians * 180 / .pi
    }

    public func difference(other: Angle) -> Float {
        var difference = degrees - other.degrees
        difference = fmod(difference + 180, 360)
        if difference < 0 { difference += 360 }
        difference -= 180
        return difference
    }

    public static func - (lhs: Angle, rhs: Float) -> Angle {
        Angle(degrees: lhs.degrees - rhs)
    }
    public static func + (lhs: Angle, rhs: Float) -> Angle {
        Angle(degrees: lhs.degrees + rhs)
    }
    public static func += (lhs: inout Angle, rhs: Float) {
        lhs.degrees += rhs
    }
}
