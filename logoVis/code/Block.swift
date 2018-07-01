import UIKit
import JavaScriptCore
import WebKit

class Block {

	private var _hash: [String:Float] = [:]
	
	func add(s:String, v: Float) {
		_hash[s] = v
	}
	
	func exists(s:String) -> Bool{
		return (_hash[s] != nil)
	}
	
	func get(s:String) -> Float? {
		return _hash[s]
	}
}
