import UIKit
import JavaScriptCore
import WebKit

class Patch:PScenePlayer {
	
	private var pos:CGPoint
	private var vars:JSON
	private var type:String
	
	init(){
		pos = CGPoint(x: 0.0, y: 0.0)
		vars = [:]
		type = "patch"
	}
	
	func setVar(name:String, val:Float){
		vars[name] = val
	}
	func getVar(name:String) -> Float{
		return vars[name] as! Float
	}
	func getPos() -> CGPoint{
		return CGPoint(x: 0.0, y: 0.0)
	}
}

