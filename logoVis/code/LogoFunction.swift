import UIKit
import JavaScriptCore
import WebKit

class LogoFunction {
	
	private var _name:String
	private var _argsNode:JSON
	private var _statementsNode:JSON
	
	init(name:String, argsNode:JSON, statementsNode:JSON){
		_name = name
		_argsNode = argsNode
		_statementsNode = statementsNode
	}
	
	func getArgs() -> JSON{
		return _argsNode
	}
	
	func getNumArgsRequired() -> Int{
		let ch:[JSON] = _argsNode["children"] as! [JSON]
		return ch.count
	}
	
	func getStatements() -> JSON{
		return _statementsNode
	}
}

typealias LogoFunctionDict = [String:LogoFunction]
