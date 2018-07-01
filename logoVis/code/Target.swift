import UIKit
import JavaScriptCore
import WebKit
import SceneKit

class Target:PScenePlayer{
	
	private var _pos:CGPoint
	private var _vars:JSON
	private var _type:String
	private var _id:String
	private var _node:SCNNode
	
	init(type:String, pos:CGPoint, node:SCNNode){
		_pos = pos
		_vars = [:]
		_type = type
		_id = UUID.init().uuidString
		_node = node
	}
	
	func getType() -> String {
		return _type
	}
	
	func getID() -> String {
		return _id
	}
	
	func consume(type:String, amt:Float){
		if(type == "fd"){
			_pos.x = _pos.x + CGFloat(amt)
		}
	}
	
	func setID(id:String){
		_id = id
	}
	
	func getNode()-> SCNNode{
		return _node
	}
	
	func consume(_:JSON){
		/*
		if(msg.type === "command"){
		if(msg.name === "fd"){
		this.data.pos.x += Math.cos(this.data.angle*PI180) * msg.amount;
		this.data.pos.y += Math.sin(this.data.angle*PI180) * msg.amount;
		}
		else if(msg.name === "rt"){
		this.data.angle += msg.amount;
		}
		else if(msg.name === "setxy"){
		this.data.pos.x = msg.amountX;
		this.data.pos.y = msg.amountY;
		}
		}
		*/
	}
	
	func getPos() -> CGPoint{
		return _pos
	}
	
	func setVar(name:String, val:Float){
		_vars[name] = val
	}
	
	func getData(){
		
	}
	
	func getVar(name:String) -> Float{
		return _vars[name] as! Float
	}
	
}
