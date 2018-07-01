import UIKit
import JavaScriptCore
import WebKit


class Target:PScenePlayer{
	
	var pos:CGPoint
	var vars:JSON
	var type:String
	
	init(){
		pos = CGPoint(x: 0.0, y: 0.0)
		vars = [:]
		type = ""
	}
	
	func getType() -> String {
		return type
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
	
	func setVar(name:String, val:Float){
		vars[name] = val
	}
	
	func getData(){
		
	}
	
	func getVar(name:String) -> Float{
		return vars[name] as! Float
	}
	
}
