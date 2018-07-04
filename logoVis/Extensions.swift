import Foundation
import CoreGraphics


public extension Int {

	public static var random: Int {
		return Int.random(n: Int.max)
	}

	public static func random(n: Int) -> Int {
		return Int(arc4random_uniform(UInt32(n)))
	}
	

	public static func random(min: Int, max: Int) -> Int {
		return Int.random(n: max - min + 1) + min
	}
}



public extension Double {

	public static var random: Double {
		return Double(arc4random()) / 0xFFFFFFFF
	}
	
	public static func random(min: Double, max: Double) -> Double {
		return Double.random * (max - min) + min
	}
}



public extension Float {
	
	public static var random: Float {
		return Float(arc4random()) / 0xFFFFFFFF
	}
	public static func random(min: Float, max: Float) -> Float {
		return Float.random * (max - min) + min
	}
}
