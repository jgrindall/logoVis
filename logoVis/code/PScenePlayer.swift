import UIKit
import JavaScriptCore
import WebKit
import SceneKit
import ReSwift

protocol PScenePlayer{
	func setVar(name:String, val:Float)
	func setID(id:String)
	func getVar(name:String) -> Float
	func getPos() -> CGPoint
	func getType() -> String
	func getID() -> String
	func consume(type:String, amt:Float)
}


