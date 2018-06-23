import UIKit
import JavaScriptCore
import WebKit

class ViewController: UIViewController, UIWebViewDelegate {

	private var playButton:UIButton?
	private var stopButton:UIButton?
	private var testButton:UIButton?
	private var procButton:UIButton?
	private var webView:UIWebView
	private var prog:Program?
	
	required init?(coder aDecoder: NSCoder) {
		self.webView = UIWebView(frame: CGRect(x: 10, y: 10, width: 10, height:10))
		super.init(nibName: nil, bundle: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.initWeb()
		self.addUI()
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
	
	func testDispatchItems() {
		let queue = DispatchQueue.global()
		var item: DispatchWorkItem!
		var i:Int = 0;
		item = DispatchWorkItem { [weak self] in
			while(true){
				if item.isCancelled { break }
				self?.heavyWork(a:i)
				i = i + 1
			}
			item = nil
		}
		queue.async(execute: item)
		queue.asyncAfter(deadline: .now() + 3) { [weak item] in
			item?.cancel()
		}
	}
	
	func heavyWork(a:Int){
		print(a)
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
		
	}
	
	@objc private func _testTapped(sender: UIButton!) {
		print("TEST")
	}
	
	@objc private func _procTapped(sender: UIButton!) {
		self.testDispatchItems()
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
			(f:Float) -> Void in
			print("view controller receives", f)
		}
		
		self.prog?.start(tree: dictionary)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
			self.prog?.cancel()
		})
	}
	
	func initUIWeb(){
		do {
			self.webView.delegate = self
			let htmlPath:String = Bundle.main.path(forResource: "index3", ofType: "html")!
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

	
