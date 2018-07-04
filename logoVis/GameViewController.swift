import UIKit
import JavaScriptCore
import WebKit
import SceneKit
import ReSwift

class GameViewController: UIViewController, UIWebViewDelegate, SCNSceneRendererDelegate {

	private var webView:UIWebView?
	private var sceneView: SCNView?
	private var prog:Program?
	private var _targets:[Target]
	private var _patches:[Patch]
	private var _nodes:[SCNNode]
	private var _floor:SCNNode?
	
	var lastUpdateTime: TimeInterval = 0
	
	private lazy var state1Subscriber: BlockSubscriber<RunningState> = BlockSubscriber<RunningState>(block: { runningState in
		print("game run", runningState)
		let s:String = store.state.scriptState.s
		if(runningState.s == "running"){
			self.run(fnName:"draw", arg:s)
		}
		else{
			self.prog?.cancel()
		}
	})

	required init(frame:CGRect){
		self._targets = []
		self._patches = []
		self._nodes = []
		super.init(nibName: nil, bundle: nil)
		self.view.frame = frame
		
	}
	
	required init(coder:NSCoder){
		self._targets = []
		self._patches = []
		self._nodes = []
		super.init(coder: coder)!
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		store.unsubscribe(self.state1Subscriber)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		init3d()
		initWeb()
		initTargets()
		initPatches()
		store.subscribe(self.state1Subscriber) { state in
			state.select { state in state.runningState }
		}
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
		for _ in 0...10{
			_patches.append(Patch())
		}
	}

	func init3d(){
		sceneView = SCNView()
		sceneView?.frame = CGRect(x: 0, y: 150, width: 650, height: 650)
		let scene = SCNScene()
		sceneView?.scene = scene
		sceneView?.showsStatistics = true
		sceneView?.preferredFramesPerSecond = 30
		sceneView?.antialiasingMode = .none
		
		let camera = SCNCamera()
		let cameraNode = SCNNode()
		cameraNode.camera = camera
		cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 4.0)
		camera.focalSize = 10.0
		//camera.focalBlurRadius = 0.005
		camera.focalDistance = 2.0
		camera.usesOrthographicProjection = true
		
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLight.LightType.ambient
		ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
		scene.rootNode.addChildNode(ambientLightNode)
		
		let light = SCNLight()
		light.type = SCNLight.LightType.omni
		let lightNode = SCNNode()
		lightNode.light = light
		lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
		
		let dLight = SCNLight()
		dLight.castsShadow = true
		dLight.type = SCNLight.LightType.directional
		dLight.zNear = 50
		dLight.zFar = 120
		dLight.orthographicScale = 30
		
		let dLightNode = SCNNode()
		dLightNode.light = dLight
		dLight.castsShadow = true
		
		var dLightTransform = SCNMatrix4Identity
		dLightTransform = SCNMatrix4Rotate(dLightTransform, -90 * .pi/180, 1, 0, 0)
		dLightTransform = SCNMatrix4Rotate(dLightTransform, 65 * .pi/180, 0, 0, 1)
		dLightTransform = SCNMatrix4Rotate(dLightTransform, -20 * .pi/180, 0, 1, 0)
		dLightTransform = SCNMatrix4Translate(dLightTransform, -20, 50, -10)
		dLightNode.transform = dLightTransform
		scene.rootNode.addChildNode(dLightNode)
		
		
		
		
		let floorGeometry = SCNBox(width: 5, height: 0.2, length: 5, chamferRadius: 0.0)
		_floor = SCNNode(geometry: floorGeometry)
		scene.rootNode.addChildNode(_floor!)
		floorGeometry.firstMaterial!.diffuse.contents = UIColor.blue
		_floor?.position.z = -5.0
		
		let cubeGeometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.005)
		var node:SCNNode
		for _ in 0...31{
			node = SCNNode(geometry: cubeGeometry)
			_nodes.append(node)
			node.position.x = Float.random(min: -1.0, max: 1.0)
			node.position.y = Float.random(min: -1.0, max: 1.0)
			node.position.z = Float.random(min: -2.0, max: 2.0)
			scene.rootNode.addChildNode(node)
		}
		cubeGeometry.firstMaterial!.diffuse.contents = UIColor.green

		scene.rootNode.addChildNode(cameraNode)
		
		sceneView!.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
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
		
		let deltaTime = time - lastUpdateTime
		let currentFPS = 1 / deltaTime
		//print("fps", deltaTime, currentFPS)
		print(_floor?.position)
		lastUpdateTime = time
	}
	
	private func _eval(s:String){
		self.webView?.stringByEvaluatingJavaScript(from: s)
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
		let ctx:JSContext = (self.webView!.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext)!
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
		self.webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 0, height:0))
		do {
			self.webView?.delegate = self
			let htmlPath:String = Bundle.main.path(forResource: "index", ofType: "html")!
			let contents:String = try String(contentsOfFile: htmlPath)
			let url:URL = URL(fileURLWithPath: htmlPath)
			self.webView?.loadHTMLString(contents, baseURL: url)
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


