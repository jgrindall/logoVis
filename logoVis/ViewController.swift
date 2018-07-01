import UIKit
import JavaScriptCore
import WebKit
import SceneKit
import ReSwift

class ViewController: UIViewController, UIWebViewDelegate, SCNSceneRendererDelegate {

	private var playButton:UIButton?
	private var stopButton:UIButton?
	private var testButton:UIButton?
	private var procButton:UIButton?
	private var webView:UIWebView
	private var sceneView: SCNView?
	private var prog:Program?
	private var cubeNode0:SCNNode?
	private var cubeNode1:SCNNode?
	private var cubeNode2:SCNNode?
	private var r0:Float = 0.0
	private var r1:Float = 0.0
	private var r2:Float = 0.0
	private var _targets:[Target]
	private var _patches:[Patch]
	
	required init?(coder aDecoder: NSCoder) {
		self.webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 0, height:0))
		_targets = [
			Target(type: "robot", pos: CGPoint(x: 0.0, y: 0.0)),
			Target(type: "robot", pos: CGPoint(x: 0.0, y: 0.0))
		]
		_patches = [
			Patch(),
			Patch(),
			Patch()
		]
		super.init(nibName: nil, bundle: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		store.unsubscribe(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.init3d()
		self.initWeb()
		self.addUI()
		store.subscribe(self) { $0.select { state in state.routingState } }
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
		self.cubeNode0 = SCNNode(geometry: cubeGeometry)
		self.cubeNode1 = SCNNode(geometry: cubeGeometry)
		self.cubeNode2 = SCNNode(geometry: cubeGeometry)
		cubeGeometry.firstMaterial!.diffuse.contents = UIColor.green

		scene.rootNode.addChildNode(cameraNode)
		scene.rootNode.addChildNode(self.cubeNode0!)
		scene.rootNode.addChildNode(self.cubeNode1!)
		scene.rootNode.addChildNode(self.cubeNode2!)
		
		sceneView!.backgroundColor = UIColor.red
		scene.rootNode.addChildNode(cameraNode)
		self.view.addSubview(sceneView!)
		
		sceneView!.delegate = self
		sceneView!.isPlaying = true
	}
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		cubeNode0?.position.x = r0
		cubeNode0?.rotation = SCNVector4(0, 0.5, 1, r0)
		cubeNode1?.position.x = r1
		cubeNode1?.rotation = SCNVector4(0, 0.5, 1, r1)
		cubeNode2?.position.x = r2
		cubeNode2?.rotation = SCNVector4(0, 0.5, 1, r2)
	}
	
	func addUI(){
		playButton = UIButton(type: UIButtonType.system)
		playButton?.setTitle("play", for: UIControlState.normal)
		playButton?.frame = CGRect(x: 50, y: 50, width: 100, height: 50)
		playButton?.addTarget(self, action: #selector(_playTapped), for: .touchUpInside)
		self.view.addSubview(playButton!)
		stopButton = UIButton(type: UIButtonType.system)
		stopButton?.setTitle("stop", for: UIControlState.normal)
		stopButton?.frame = CGRect(x: 250, y: 50, width: 100, height: 50)
		stopButton?.addTarget(self, action: #selector(_stopTapped), for: .touchUpInside)
		self.view.addSubview(stopButton!)
		procButton = UIButton(type: UIButtonType.system)
		procButton?.setTitle("proc", for: UIControlState.normal)
		procButton?.frame = CGRect(x: 450, y: 50, width: 100, height: 50)
		procButton?.addTarget(self, action: #selector(_procTapped), for: .touchUpInside)
		self.view.addSubview(procButton!)
		
		testButton = UIButton(type: UIButtonType.system)
		testButton?.setTitle("TEST", for: UIControlState.normal)
		testButton?.frame = CGRect(x: 650, y: 50, width: 100, height: 50)
		testButton?.addTarget(self, action: #selector(_testTapped), for: .touchUpInside)
		self.view.addSubview(testButton!)
	}
	
	@objc private func _playTapped(sender: UIButton!) {
		var s:String = "to test fd 0.01 end"
		s = s + "to setup-rabbit rt 45 activate-daemon daemon-rabbit-eat activate-daemon daemon-rabbit-walk end"
		s = s + "to setup-robot set-var age 0 activate-daemon daemon-robot-walk end"
		s = s + "to setup-patch set-var grass 0.3 activate-daemon daemon-patch-grow end"
		s = s + "to daemon-robot-walk test rt 0.05 end"
		s = s + "to daemon-rabbit-walk fd 0.02 rt 0.05 end"
		s = s + "to daemon-rabbit-eat set-patch-var grass 0 end"
		s = s + "to daemon-patch-grow set-var grass (get-var grass + 0.01) end"
		self.run(fnName:"draw", arg:s)
		store.dispatch(StatusAction(status: "123"))
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
	
	@objc private func _stopTapped(sender: UIButton!) {
		self.prog?.cancel()
	}
	
	@objc private func _testTapped(sender: UIButton!) {
		print("TEST")
	}
	
	@objc private func _procTapped(sender: UIButton!) {
		
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
			print(id, s, f)
			self.r0 = self.r0 + 0.005
			if(self.r0 > 2.0){
				self.r0 = -2.0
			}
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
	
	override var prefersStatusBarHidden : Bool {
		return true
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}


extension ViewController: StoreSubscriber {
	typealias StoreSubscriberStateType = MyState
	
	func newState(state: MyState) {
		print(state)
	}
}

	
