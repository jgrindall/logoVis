import UIKit
import JavaScriptCore
import WebKit

private class Helper{

	static func getType(name:String) -> String{
		let subs:[Substring] = name.split(separator: "-")
		return String(subs[0])
	}
	
	static func getPlayerName(name:String) -> String{
		let subs:[Substring] = name.split(separator: "-")
		return String(subs[1])
	}
	
	static func getFunctionName(name:String) -> String{
		let subs:[Substring] = name.split(separator: "-")
		return String(subs[2])
	}

}

class SymTable {
	
	private var _blocks:			[Block]
	private var _functions:			LogoFunctionDict
	private var _currentPlayer:		PScenePlayer?
	private var _setups:			[String:LogoFunction]
	private var _daemons:			[String:LogoFunctionDict]
	private var _activeDaemons:		[String:LogoFunctionDict]
	
	init(){
		_blocks = []
		_functions = [:]
		_setups = [:]
		_daemons = [:]
		_activeDaemons = [:]
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
	
	func setPlayer(player:PScenePlayer){
		_currentPlayer = player
	}
	
	func getPlayer()->PScenePlayer{
		return _currentPlayer!
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
	
	func addToActiveDaemon(name:String, fnName:String, fn:LogoFunction){
		if var daemonList = _activeDaemons[name] {
			daemonList[fnName] = fn
		}
		else{
			_activeDaemons[name] = [fnName:fn]
		}
	}
	
	func addToSetups(name:String, fn:LogoFunction){
		_setups[name] = fn
	}
	
	func addToDaemon(name:String, fnName:String, fn:LogoFunction){
		if var daemonList = _daemons[name] {
			daemonList[fnName] = fn
		}
		else{
			_daemons[name] = [fnName:fn]
		}
	}
	
	func activateDaemon(name:String){
		let playerType:String = Helper.getPlayerName(name:name)
		let fnName = Helper.getFunctionName(name: name)
		let daemonList:LogoFunctionDict = _daemons[playerType]!
		if let fn:LogoFunction = daemonList[fnName] {
			addToActiveDaemon(name: playerType, fnName:fnName, fn: fn)
		}
		//print(_activeDaemons)
	}
		
	func getSetupForType(type:String) -> LogoFunction{
		return _setups[type]!
	}
	
	func getDaemonsForType(type:String) -> [LogoFunction]{
		if let daemonList:LogoFunctionDict = _daemons[type] {
			return Array(daemonList.values)
		}
		return []
	}
	
	func getActiveDaemonsForType(type:String) -> [LogoFunction]{
		if let daemonList:LogoFunctionDict = _activeDaemons[type] {
			return Array(daemonList.values)
		}
		return []
	}

	func addFunction(name:String, argsNode:JSON, statementsNode:JSON){
		let fn = LogoFunction(name: name, argsNode: argsNode, statementsNode: statementsNode)
		var playerName:String
		var fnName:String
		_functions[name] = fn
		if(Helper.getType(name:name) == "setup"){
			playerName = Helper.getPlayerName(name:name)
			addToSetups(name:playerName, fn:fn)
		}
		else if(Helper.getType(name:name) == "daemon"){
			playerName = Helper.getPlayerName(name:name)
			fnName = Helper.getFunctionName(name: name)
			addToDaemon(name:playerName, fnName:fnName, fn:fn)
		}
	}

}

