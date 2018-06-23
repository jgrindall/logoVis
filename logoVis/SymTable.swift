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

class SymTable {
	
	private var _blocks:[Block]
	private var _functions:[String:LogoFunction]
	
	init(){
		_blocks = []
		_functions = [:]
	}
	
	func enterBlock(){
		_blocks.append(Block())
	}
	
	func exitBlock(){
		_ = _blocks.popLast()
	}
	
	func add(name:String, val:Float){
		let block = getCurrentBlock()
		block?.add(s: name, v: val)
	}
	
	func get(name:String)->Float?{
		var block:Block
		let numBlocks:Int = _blocks.count
		for i in 0..<numBlocks {
			block = _blocks[numBlocks - i - 1]
			if(block.exists(s: name)){
				return block.get(s: name)!
			}
		}
		print("var not found", name)
		return nil
	}
	
	func clear(){
		_blocks = []
	}
	
	func getCurrentBlock() -> Block?{
		return _blocks.last
	}
	
	func hasFunction(s:String) -> Bool{
		return (_functions[s] != nil)
	}
	
	func getFunctionByName(s:String) -> LogoFunction?{
		return _functions[s]
	}
	
	func addFunction(name:String, argsNode:JSON, statementsNode:JSON){
		_functions[name] = LogoFunction(name: name, argsNode: argsNode, statementsNode: statementsNode)
	}

}
