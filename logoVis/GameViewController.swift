import UIKit
import JavaScriptCore
import WebKit
import SceneKit
import ReSwift

class GameViewController: UIViewController, UIWebViewDelegate, SCNSceneRendererDelegate {

	private var webView:UIWebView
	private var sceneView: SCNView?
	private var prog:Program?
	private var _targets:[Target]
	private var _patches:[Patch]
	private var _nodes:[SCNNode]
	
	required init(frame:CGRect){
		self.webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 0, height:0))
		self.view.frame = frame
		self._targets = []
		self._patches = []
		self._nodes = []
		super.init(nibName: nil, bundle: nil)
		
	}
	
	required init(coder:NSCoder){
		super.init(coder: coder)!
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		store.unsubscribe(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		init3d()
		initWeb()
		initTargets()
		initPatches()
		store.subscribe(self) { $0.select { state in state.routingState } }
	}
	
	func initTargets(){
		for i in 0...10{
			_targets.append(Target(type: "robot", pos: CGPoint(x: 0.0, y: 0.0), node:_nodes[i]))
		}
		for i in 10...20{
			_targets.append(Target(type: "rabbit", pos: CGPoint(x: 0.0, y: 0.0), node:_nodes[i]))
		}
	}
	
	func initPatches(){
		for _ in 0...100{
			_patches.append(Patch())
		}
	}

	func init3d(){
		sceneView = SCNView()
		sceneView?.frame = CGRect(x: 0, y: 150, width: 650, height: 650)
		let scene = SCNScene()
		sceneView?.scene = scene
		sceneView?.showsStatistics = true
		
		let camera = SCNCamera()
		let cameraNode = SCNNode()
		cameraNode.camera = camera
		cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 3.0)
		
		let light = SCNLight()
		light.type = SCNLight.LightType.omni
		let lightNode = SCNNode()
		lightNode.light = light
		lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
		
		let cubeGeometry = SCNBox(width: 1.5, height: 1.5, length: 1.0, chamferRadius: 0.1)
		var node:SCNNode
		for _ in 0...31{
			node = SCNNode(geometry: cubeGeometry)
			_nodes.append(node)
			scene.rootNode.addChildNode(node)
		}
		cubeGeometry.firstMaterial!.diffuse.contents = UIColor.green

		scene.rootNode.addChildNode(cameraNode)
		
		sceneView!.backgroundColor = UIColor.red
		scene.rootNode.addChildNode(cameraNode)
		self.view.addSubview(sceneView!)
		
		sceneView!.delegate = self
		sceneView!.isPlaying = true
	}
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		var pos:CGPoint
		for target in _targets{
			pos = target.getPos()
			target.getNode().position.x = Float(pos.x)
			target.getNode().position.y = Float(pos.y)
		}
	}
	
	private func _eval(s:String){
		self.webView.stringByEvaluatingJavaScript(from: s)
	}
	
	public func run(fnName:String) {
		_eval(s:fnName + "()")
	}
	
	public func run(fnName:String, arg:String) {
		_eval(s:fnName + "(\'" + arg + "\')")
	}
	
	func webViewDidStartLoad(_ webView: UIWebView) {
		print("webViewDidStartLoad")
	}
	
	func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
		print(error as Any)
	}
	
	func webViewDidFinishLoad(_ webView: UIWebView){
		let ctx:JSContext = (self.webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext)!
		let logFunction: @convention(block) (String) -> Void = { (msg: String) in
			print("output:", msg)
		}
		let iosCallbackFunction: @convention(block) (String) -> Void = { (msg: String) in
			let jsonData = msg.data(using: .utf8)
			let dictionary:JSON = try! JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves) as! JSON
			self.visit(dictionary:dictionary)
		}
		ctx.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, to: AnyObject.self), forKeyedSubscript: "log" as NSCopying & NSObjectProtocol)
		ctx.objectForKeyedSubscript("iosBridge").setObject(unsafeBitCast(iosCallbackFunction, to: AnyObject.self), forKeyedSubscript: "callback" as NSCopying & NSObjectProtocol)
	}
	
	func visit(dictionary:JSON){
		self.prog = Program()
		self.prog?.receive = {
			(id:String, s:String, f:Float) -> Void in
			//print(id, s, f)
		}
		
		self.prog?.start(tree: dictionary, targets:_targets, patches:_patches)
	}
	
	func initUIWeb(){
		do {
			self.webView.delegate = self
			let htmlPath:String = Bundle.main.path(forResource: "index", ofType: "html")!
			let contents:String = try String(contentsOfFile: htmlPath)
			let url:URL = URL(fileURLWithPath: htmlPath)
			self.webView.loadHTMLString(contents, baseURL: url)
		}
		catch (_) {
			print("Error while loading")
		}
	}
	
	func initWeb(){
		self.initUIWeb();
	}
	
	func didFailLoadWithError(v:UIWebView){
		print("error");
	}


}


extension GameViewController: StoreSubscriber {
	typealias StoreSubscriberStateType = MyState
	
	func newState(state: MyState) {
		print(state)
	}
}

	
