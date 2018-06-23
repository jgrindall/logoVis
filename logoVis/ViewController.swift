import UIKit
import JavaScriptCore
import WebKit
import SceneKit
import ReSwift

struct AppState: StateType {
	var count = 0
}

struct AddAction: Action { }

func appReducer(action: Action, state: AppState?) -> AppState {
	var state = state ?? AppState()
	
	switch action {
	case let addAction as AddAction: state.count += 1
	default: break
	}
	
	return state
}

let store = Store(
	reducer: appReducer,
	state: AppState(),
	middleware: [])


class ViewController: UIViewController, UIWebViewDelegate, SCNSceneRendererDelegate {

	private var playButton:UIButton?
	private var stopButton:UIButton?
	private var testButton:UIButton?
	private var procButton:UIButton?
	private var webView:UIWebView
	private var sceneView: SCNView?
	private var prog:Program?
	private var cubeNode:SCNNode?
	private var robot:Float = 0.0
	
	required init?(coder aDecoder: NSCoder) {
		self.webView = UIWebView(frame: CGRect(x: 10, y: 10, width: 10, height:10))
		super.init(nibName: nil, bundle: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.init3d()
		self.initWeb()
		self.addUI()
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
		self.cubeNode = SCNNode(geometry: cubeGeometry)
		
		cubeGeometry.firstMaterial!.diffuse.contents = UIColor.green
		

		cubeNode?.rotation = SCNVector4(0.0, 1.0, 2.0, 0.0)
		
		//scene.rootNode.addChildNode(lightNode)
		scene.rootNode.addChildNode(cameraNode)
		scene.rootNode.addChildNode(self.cubeNode!)
		
		sceneView!.backgroundColor = UIColor.red
		scene.rootNode.addChildNode(cameraNode)
		self.view.addSubview(sceneView!)
		
		sceneView!.delegate = self
		sceneView!.isPlaying = true
	}
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		cubeNode?.position.x = robot
		cubeNode?.rotation = SCNVector4(0, 0.5, 1, robot)
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
		let r:Int = Int(arc4random_uniform(1000) + 100)
		let s:String = "rpt 55555555 [ fd " + String(r) + "]"
		print(s)
		self.run(fnName:"draw", arg:s)
	}
	
	public func run(fnName:String) {
		let s:String = fnName + "()"
		print("stringByEvaluatingJavaScript", s)
		self.webView.stringByEvaluatingJavaScript(from: s)
	}
	
	public func run(fnName:String, arg:String) {
		let s:String = fnName + "(\'" + arg + "\')"
		print("stringByEvaluatingJavaScript", s)
		self.webView.stringByEvaluatingJavaScript(from: s)
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
			print(dictionary)
			self.visit(dictionary:dictionary)
		}
		ctx.objectForKeyedSubscript("console").setObject(unsafeBitCast(logFunction, to: AnyObject.self), forKeyedSubscript: "log" as NSCopying & NSObjectProtocol)
		ctx.objectForKeyedSubscript("iosBridge").setObject(unsafeBitCast(iosCallbackFunction, to: AnyObject.self), forKeyedSubscript: "callback" as NSCopying & NSObjectProtocol)
	}
	
	func visit(dictionary:JSON){
		self.prog = Program()
		self.prog?.receive = {
			(s:String, f:Float) -> Void in
			self.robot = self.robot + 0.005
			if(self.robot > 2.0){
				self.robot = -2.0
			}
		}
		self.prog?.start(tree: dictionary)
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

	
