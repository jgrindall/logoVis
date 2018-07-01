import UIKit
import JavaScriptCore
import WebKit

struct Stack<Float> {
	fileprivate var array: [Float] = []
	
	mutating func push(_ element: Float) {
		array.append(element)
	}
	
	mutating func pop() -> Float? {
		return array.popLast()
	}
	
	mutating func popForChildren(node:JSON) -> [Float]{
		let ch:[JSON] = (node["children"] as! [JSON])
		return self.popN(n: ch.count)
	}
	
	mutating func popN(n:Int) -> [Float]{
		var vals:[Float] = [ ];
		for _ in 0..<n{
			let num:Float = self.pop()!
			vals.append(num)
		}
		return vals
	}
	
	func peek() -> Float? {
		return array.last
	}
}
