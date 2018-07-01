import UIKit
import JavaScriptCore
import WebKit


class Target:PScenePlayer{
	
	private var _pos:CGPoint
	private var _vars:JSON
	private var _type:String
	private var _id:String
	
	init(type:String, pos:CGPoint){
		_pos = pos
		_vars = [:]
		_type = type
		_id = UUID.init().uuidString
	}
	
	func getType() -> String {
		return _type
	}
	
	func getID() -> String {
		return _id
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
