import UIKit
import JavaScriptCore
import WebKit
import SceneKit
import ReSwift

protocol PScenePlayer{
	func setVar(name:String, val:Float)
	func getVar(name:String) -> Float
	func getPos() -> CGPoint
}


