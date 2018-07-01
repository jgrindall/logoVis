import UIKit
import JavaScriptCore
import WebKit

private class Helper{
	static func mult(vals:[Float]) -> Float {
		var num:Float = 1.0
		for val in vals {
			num = num * val
		}
		return num
	}
	static func add(vals:[Float]) -> Float {
		var num:Float = 0.0
		for val in vals {
			num = num + val
		}
		return num
	}
}

class Visitor {
	
	public var receive: ((_ id:String, _ s:String, _ f:Float) -> Void)?
	public var isActive:(() -> Bool)?
	private var _stack:Stack<Float>
	private var _symTable:SymTable
	private var _targets:[Target]
	private var _patches:[Patch]
	
	init(){
		_stack = Stack()
		_symTable = SymTable()
		_targets = []
		_patches = []
	}
	
	private func visitstart(node:JSON){
		_symTable.enterBlock()
		if(self.isActive!()){
			visitchildren(node:node)
		}
	}
	
	private func visitchildren(node:JSON){
		for node in (node["children"] as! [JSON]) {
			if(self.isActive!()){
				visitNode(node: node)
			}
		}
	}
	
	private func visitrptstmt(node:JSON){
		let ch:[JSON] = node["children"] as! [JSON]
		visitNode(node:ch[0])
		let num:Int = Int(round(_stack.pop()!))
		for i in 0...num{
			if(self.isActive!()){
				_symTable.add(name: "repcount", val: Float(i))
				visitNode(node:ch[1])
			}
			else{
				break
			}
		}
	}
	
	private func visitrpttargetsstmt(node:JSON){
		let ch:[JSON] = node["children"] as! [JSON]
		let node = ch[0]
		for target in _targets{
			_symTable.setPlayer(player: target)
			visitNode(node: node)
		}
	}
	
	private func visitexpression(node:JSON){
		visitchildren(node:node)
		if(self.isActive!()){
			let vals:[Float] = _stack.popForChildren(node: node)
			_stack.push(Helper.add(vals: vals))
		}
	}
	
	private func visitnumber(node:JSON){
		if let strVal = (node["value"] as? String) {
			print("its a string")
			if(strVal == "random"){
				_stack.push(57);
			}
		}
		else{
			_stack.push(node["value"] as! Float)
		}
	}
	
	private func visitdivterm(node:JSON){
		visitchildren(node:node)
		let num:Float = _stack.pop()!
		if(num == 0){
			//postError("Division by zero");
		}
		else{
			_stack.push(1.0/num);
		}
	}
	
	private func visitstopstmt(node:JSON){
		print("stop")
		//throw VisitError.stopError("stop")
	}
	
	private func visitdefinefnstmt(node:JSON){
		let name = node["name"] as! String
		let argsNode = node["args"] as! JSON
		let statementsNode = node["stmts"] as! JSON
		if(self.isActive!()){
			_symTable.addFunction(name: name, argsNode: argsNode, statementsNode: statementsNode)
		}
	}
	
	private func executeFunctions(fs:[LogoFunction]){
		for f:LogoFunction in fs {
			if(self.isActive!()){
				executeFunction(f: f)
			}
		}
	}
	
	private func executeFunction(f:LogoFunction){
		let numArgs:Int = f.getNumArgsRequired()
		let vals = _stack.popN(n:numArgs)
		let argsNode:JSON = f.getArgs()
		let ch:[JSON] = argsNode["children"] as! [JSON]
		var varName:String
		for i in 0..<numArgs{
			varName = ch[i]["name"] as! String
			_symTable.add(name: varName, val: vals[numArgs - 1 - i])
		}
		return visitNode(node:f.getStatements())
	}
	
	private func visitcallfnstmt(node:JSON){
		let name:String = node["name"] as! String
		if(_symTable.hasFunction(s: name)){
			let f:LogoFunction = _symTable.getFunctionByName(s:name)!
			let argsNode:JSON = node["args"] as! JSON
			let ch:[JSON] = argsNode["children"] as! [JSON]
			if(f.getNumArgsRequired() == ch.count){
				_symTable.enterBlock();
				visitchildren(node:argsNode);
				executeFunction(f:f);
				_symTable.exitBlock();
			}
		}
	}
	
	private func visitmakestmt(node:JSON){
		let ch:[JSON] = node["children"] as! [JSON]
		let name:String = ch[0]["name"] as! String
		visitNode(node:ch[1])
		_symTable.add(name: name, val: _stack.pop()!)
	}
	
	private func visitusevar(node:JSON){
		let num:Float? = _symTable.get(name:node["name"] as! String);
		if let floatVal = (num) {
			_stack.push(floatVal)
		}
		else{
			print("var not found")
		}
	}
	
	private func getPatchVar(name:String) -> Float{
		let player:PScenePlayer = _symTable.getPlayer()
		let pos:CGPoint = player.getPos()
		let i:Int = Int(pos.x)
		let patch:Patch = _patches[i]
		return patch.getVar(name:name)
	};
	
	private func setPatchVar(name:String, val:Float){
		let player:PScenePlayer = _symTable.getPlayer()
		let pos:CGPoint = player.getPos()
		let i:Int = Int(pos.x)
		let patch:Patch = _patches[i]
		patch.setVar(name: name, val: val)
	};
	
	private func visitgetvarstmt(node:JSON){
		let player:PScenePlayer = _symTable.getPlayer()
		let val = player.getVar(name: node["name"] as! String)
		_stack.push(val)
	}
	
	private func visitsetvarstmt(node:JSON){
		visitchildren(node:node)
		let player = _symTable.getPlayer()
		let val:Float = _stack.pop()!
		player.setVar(name: node["name"] as! String, val: val)
	}
	
	private func visitsetpatchvarstmt(node:JSON){
		visitchildren(node:node)
		let val:Float = _stack.pop()!
		setPatchVar(name: node["name"] as! String, val:val)
	}
	
	private func visitgetpatchvarstmt(node:JSON){
		_stack.push(getPatchVar(name: node["name"] as! String))
	}
	
	private func visitminusexpression(node:JSON){
		visitchildren(node:node)
		let num:Float = _stack.pop()!
		_stack.push(-1.0*num)
	}
	
	private func visitnegate(node:JSON){
		visitchildren(node:node)
		_stack.push(-1.0*_stack.pop()!)
	}
	
	private func visittimesordivterms(node:JSON){
		visitchildren(node:node)
		let vals = _stack.popForChildren(node:node)
		_stack.push(Helper.mult(vals: vals))
	}
	
	private func visitfdstmt(node:JSON){
		visitchildren(node:node)
		if(self.isActive!()){
			if let receive = self.receive {
				receive(_symTable.getPlayer().getID(), "fd", _stack.pop()!)
			}
		}
	}
	
	private func visitbkstmt(node:JSON){
		visitchildren(node:node)
		print("BK:", _stack.pop()!)
	}
	
	private func visitrtstmt(node:JSON){
		visitchildren(node:node)
		print("RT:", _stack.pop()!)
	}
	
	private func visitltstmt(node:JSON){
		visitchildren(node:node)
		print("LT:", _stack.pop()!)
	}
	
	private func visitarcrtstmt(node:JSON){
		visitchildren(node:node)
		let amount1 = _stack.pop()!
		let amount2 = _stack.pop()!
		print("ARCRT:", "radius", amount1, "angle", amount2)
	}
	
	private func visitactivatedaemonstmt(node:JSON){
		_symTable.activateDaemon(name: node["name"] as! String)
	}
	
	private func visitarcltstmt(node:JSON){
		visitchildren(node:node)
		let amount1 = _stack.pop()!, amount2 = _stack.pop()!
		print("ARCLT:", "radius", amount1, "angle", amount2)
	}
	
	private func visitarcstmt(node:JSON){
		visitchildren(node:node)
		let amount1 = _stack.pop()!, amount2 = _stack.pop()!
		print("ARC:", "radius", amount1, "angle", amount2)
	}

	private func visitmultexpression(node:JSON){
		visitchildren(node:node)
		if(self.isActive!()){
			let vals = _stack.popForChildren(node: node)
			_stack.push(Helper.mult(vals: vals))
		}
	}
	
	private func _visitNode(node:JSON){
		let t:String = node["type"] as! String
		if(t=="start"){
			return visitstart(node:node)
		}
		else if(t=="insidestmt"){
			return visitchildren(node:node)
		}
		else if(t=="penupstmt"){
			//return visitpenupstmt(node)
		}
		else if(t=="homestmt"){
			//return visithomestmt(node)
		}
		else if(t=="pendownstmt"){
			//return visitpendownstmt(node)
		}
		else if(t == "definefnstmt"){
			return visitdefinefnstmt(node:node)
		}
		else if(t == "callfnstmt"){
			return visitcallfnstmt(node:node)
		}
		else if(t=="fdstmt"){
			return visitfdstmt(node:node)
		}
		else if(t=="arcstmt"){
			return visitarcstmt(node:node)
		}
		else if(t=="arcrtstmt"){
			return visitarcrtstmt(node:node)
		}
		else if(t=="arcltstmt"){
			return visitarcltstmt(node:node)
		}
		else if(t=="bkstmt"){
			return visitbkstmt(node:node)
		}
		else if(t=="rtstmt"){
			return visitrtstmt(node:node)
		}
		else if(t=="ltstmt"){
			return visitltstmt(node:node)
		}
		else if(t=="rptstmt"){
			return visitrptstmt(node:node)
		}
		else if(t=="rpttargetsstmt"){
			return visitrpttargetsstmt(node: node)
		}
		else if(t=="makestmt"){
			return visitmakestmt(node:node)
		}
		else if(t=="expression"){
			return visitexpression(node:node)
		}
		else if(t=="insidefnlist"){
			return visitchildren(node:node)
		}
		else if(t=="outsidefnlist"){
			return visitchildren(node:node)
		}
		else if(t=="expression"){
			return visitexpression(node:node)
		}
		else if(t=="multexpression"){
			return visitmultexpression(node:node)
		}
		else if(t=="plusorminus"){
			return visitchildren(node:node)
		}
		else if(t=="plusexpression"){
			return visitchildren(node:node)
		}
		else if(t=="minusexpression"){
			return visitminusexpression (node:node)
		}
		else if(t=="unaryexpression"){
			return visitchildren(node:node)
		}
		else if(t=="timesordivterms"){
			return visittimesordivterms(node:node)
		}
		else if(t=="timesordivterm"){
			return visitchildren(node:node)
		}
		else if(t=="timesterm"){
			return visitchildren(node:node)
		}
		else if(t=="bgstmt"){
			//return visitbgstmt(node)
		}
		else if(t=="colorstmt"){
			//return visitcolorstmt(node)
		}
		else if(t=="plusexpression"){
			return visitchildren(node:node)
		}
		else if(t=="negate"){
			return visitnegate(node:node)
		}
		else if(t=="numberexpression"){
			return visitchildren(node:node)
		}
		else if(t=="divterm"){
			return visitdivterm(node:node)
		}
		else if(t=="number"){
			return visitnumber(node:node)
		}
		else if(t=="thickstmt"){
			//return visitthickstmt(node)
		}
		else if(t=="booleanstmt"){
			//return visitbooleanstmt(node)
		}
		else if(t=="stopstmt"){
			return visitstopstmt(node:node)
		}
		else if(t=="compoundbooleanstmt"){
			//return visitcompoundbooleanstmt(node)
		}
		else if(t=="booleanval"){
			//return visitbooleanval(node)
		}
		else if(t=="getvarstmt"){
			return visitgetvarstmt(node:node)
		}
		else if(t=="getpatchvarstmt"){
			return visitgetpatchvarstmt(node: node)
		}
		else if(t=="usevar"){
			return visitusevar(node:node)
		}
		else if(t=="setxy"){
			//return visitsetxy(node)
		}
		else if(t=="sqrtexpression"){
			//return visitsqrtexpression(node)
		}
		else if(t=="sinexpression"){
			//return visitsinexpression(node)
		}
		else if(t=="cosexpression"){
			//return visitcosexpression(node)
		}
		else if(t=="tanexpression"){
			//return visittanexpression(node)
		}
		else if(t=="labelstmt"){
			//return visitlabelstmt(node)
		}
		else if(t=="activatedaemonstmt"){
			return visitactivatedaemonstmt(node: node)
		}
		else if(t=="setvarstmt"){
			return visitsetvarstmt(node: node)
		}
		else if(t=="setpatchvarstmt"){
			return visitsetpatchvarstmt(node: node)
		}
	}
	
	private func visitNode(node:JSON){
		if (isActive!()) {
			_visitNode(node: node)
		}
		else{
			return
		}
	}
	
	private func setupTargets(){
		for target:Target in _targets {
			if (isActive!()) {
				_symTable.setPlayer(player:target)
				let fn:LogoFunction = _symTable.getSetupForType(type: target.getType())
				executeFunction(f: fn)
			}
		}
	}
	
	private func setupPatches(){
		for patch:Patch in _patches {
			if (isActive!()) {
				_symTable.setPlayer(player:patch)
				let f = _symTable.getSetupForType(type: "patch")
				executeFunction(f: f)
			}
		}
	}
	
	private func tickTargets(){
		for target in _targets{
			if (isActive!()) {
				let type:String = target.getType()
				let fs = _symTable.getActiveDaemonsForType(type: type)
				_symTable.setPlayer(player: target)
				executeFunctions(fs: fs)
			}
		}
	};
	private func tickPatches(){
		for patch in _patches{
			if (isActive!()) {
				let fs = _symTable.getActiveDaemonsForType(type: "patch")
				_symTable.setPlayer(player: patch)
				executeFunctions(fs: fs)
			}
		}
	};
	
	private func runDaemons(){
		var active = isActive!()
		while(active){
			tickTargets()
			active = isActive!()
			tickPatches()
			active = isActive!()
		}
	}
	
	public func start(tree:JSON, targets:[Target], patches:[Patch]){
		_targets = targets
		_patches = patches
		visitNode(node:tree)
		print("done")
		if let receive = self.receive {
			receive("done", "done", 0)
		}
		setupPatches()
		setupTargets()
		runDaemons()
	}

}


