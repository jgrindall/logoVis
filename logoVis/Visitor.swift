import UIKit
import JavaScriptCore
import WebKit

typealias JSON = [String: Any]

class Helper{
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

enum VisitError: Error {
	case notFoundError(String)
	case stopError(String)
	case divZero(String)
}

struct Stack<Float> {
	fileprivate var array: [Float] = []
	
	mutating func push(_ element: Float) {
		array.append(element)
	}
	
	mutating func pop() -> Float? {
		return array.popLast()
	}
	
	mutating func popForChildren(node:JSON) -> [Float]{
		let ch:[JSON] = (node["children"] as! [JSON])
		return self.popN(n: ch.count)
	}
	
	mutating func popN(n:Int) -> [Float]{
		var vals:[Float] = [ ];
		for _ in 0..<n{
			let num:Float = self.pop()!
			vals.append(num)
		}
		return vals
	}
	
	func peek() -> Float? {
		return array.last
	}
}

class Visitor {
	
	public var receive: ((_ s:String, _ f:Float) -> Void)?
	public var isActive:(() -> Bool)?
	private var _stack:Stack<Float>
	private var _symTable:SymTable
	
	init(){
		_stack = Stack()
		_symTable = SymTable()
	}
	
	func visitstart(node:JSON){
		_symTable.enterBlock()
		if(self.isActive!()){
			visitchildren(node:node)
		}
	}
	
	func visitchildren(node:JSON){
		for node in (node["children"] as! [JSON]) {
			if(self.isActive!()){
				visitNode(node: node)
			}
			else{
				break
			}
		}
	}
	
	func visitrptstmt(node:JSON){
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
	
	func visitexpression(node:JSON){
		visitchildren(node:node)
		let vals:[Float] = _stack.popForChildren(node: node)
		_stack.push(Helper.add(vals: vals))
	}
	
	func visitnumber(node:JSON){
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
	
	func visitdivterm(node:JSON){
		visitchildren(node:node)
		let num:Float = _stack.pop()!
		if(num == 0){
			//postError("Division by zero");
		}
		else{
			_stack.push(1.0/num);
		}
	}
	
	func visitstopstmt(node:JSON){
		print("stop")
		//throw VisitError.stopError("stop")
	}
	
	func visitdefinefnstmt(node:JSON){
		let name = node["name"] as! String
		let argsNode = node["args"] as! JSON
		let statementsNode = node["stmts"] as! JSON
		if(self.isActive!()){
			_symTable.addFunction(name: name, argsNode: argsNode, statementsNode: statementsNode)
		}
	}
	
	func executeFunction(f:LogoFunction){
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
	
	func visitcallfnstmt(node:JSON){
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
	
	func visitmakestmt(node:JSON){
		let ch:[JSON] = node["children"] as! [JSON]
		let name:String = ch[0]["name"] as! String
		visitNode(node:ch[1])
		_symTable.add(name: name, val: _stack.pop()!)
	}
	
	func visitusevar(node:JSON){
		let num:Float? = _symTable.get(name:node["name"] as! String);
		if let floatVal = (num) {
			_stack.push(floatVal)
		}
		else{
			print("var not found")
		}
	}
	
	func visitgetvarstmt(node:JSON){
		//target = symTable.getTarget();
		//stack.push(target.getVar(node.name));
	}
	
	func visitminusexpression(node:JSON){
		visitchildren(node:node)
		let num:Float = _stack.pop()!
		_stack.push(-1.0*num)
	}
	
	func visitnegate(node:JSON){
		visitchildren(node:node)
		_stack.push(-1.0*_stack.pop()!)
	}
	
	func visittimesordivterms(node:JSON){
		visitchildren(node:node)
		let vals = _stack.popForChildren(node:node)
		_stack.push(Helper.mult(vals: vals));
	}
	
	func visitfdstmt(node:JSON){
		visitchildren(node:node)
		if(self.isActive!()){
			if let receive = self.receive {
				receive("fd", _stack.pop()!)
			}
		}
	}
	
	func visitbkstmt(node:JSON){
		visitchildren(node:node)
		print("BK:", _stack.pop()!)
	}
	
	func visitrtstmt(node:JSON){
		visitchildren(node:node)
		print("RT:", _stack.pop()!)
	}
	
	func visitltstmt(node:JSON){
		visitchildren(node:node)
		print("LT:", _stack.pop()!)
	}
	
	func visitarcrtstmt(node:JSON){
		visitchildren(node:node)
		let amount1 = _stack.pop()!
		let amount2 = _stack.pop()!
		print("ARCRT:", "radius", amount1, "angle", amount2)
	}
	
	func visitarcltstmt(node:JSON){
		visitchildren(node:node)
		let amount1 = _stack.pop()!, amount2 = _stack.pop()!
		print("ARCLT:", "radius", amount1, "angle", amount2)
	}
	
	func visitarcstmt(node:JSON){
		visitchildren(node:node)
		let amount1 = _stack.pop()!, amount2 = _stack.pop()!
		print("ARC:", "radius", amount1, "angle", amount2)
	}

	func visitmultexpression(node:JSON){
		visitchildren(node:node)
		let vals = _stack.popForChildren(node: node)
		_stack.push(Helper.mult(vals: vals))
	}
	
	func _visitNode(node:JSON){
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
			//return visitrpttargetsstmt(node)
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
			//return visitgetpatchvarstmt(node)
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
			//return visitactivatedaemonstmt(node)
		}
		else if(t=="setvarstmt"){
			//return visitsetvarstmt(node)
		}
		else if(t=="setpatchvarstmt"){
			//return visitsetpatchvarstmt(node)
		}
	}
	
	func visitNode(node:JSON) {
		if (isActive!()) {
			_visitNode(node: node)
		}
		else{
			return;
		}
	}
	
	public func start(tree:JSON){
		visitNode(node:tree)
		print("done")
		if let receive = self.receive {
			receive("done", 0)
		}
		//setupPatches();
		//setupTargets();
		//runDaemons();
	}
	

}


