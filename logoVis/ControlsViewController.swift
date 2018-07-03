import UIKit
import JavaScriptCore
import WebKit
import SceneKit
import ReSwift

class ControlsViewController: UIViewController {

	private var playButton:UIButton?
	private var stopButton:UIButton?
	private var testButton:UIButton?
	private var procButton:UIButton?
	
	required init(frame:CGRect){
		super.init(nibName: nil, bundle: nil)
		self.view.frame = frame
		print(frame);
	}
	
	required init(coder:NSCoder){
		super.init(coder: coder)!
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		store.unsubscribe(self)
	}
	
	override func viewDidLoad() {
		print("VDL")
		super.viewDidLoad()
		addUI()
		store.subscribe(self) { $0.select { state in state.runningState } }
	}
	
	func addUI(){
		print("addUI")
		playButton = UIButton(type: UIButtonType.system)
		playButton?.setTitle("play", for: UIControlState.normal)
		playButton?.frame = CGRect(x: 50, y: 20, width: 100, height: 50)
		playButton?.addTarget(self, action: #selector(_playTapped), for: .touchUpInside)
		self.view.addSubview(playButton!)
		
		playButton?.backgroundColor = UIColor.yellow
		playButton?.layer.borderColor = UIColor.green.cgColor
		playButton?.layer.borderWidth = 0.5
		playButton?.layer.cornerRadius = 10.0
		
		
		stopButton = UIButton(type: UIButtonType.system)
		stopButton?.setTitle("stop", for: UIControlState.normal)
		stopButton?.frame = CGRect(x: 250, y: 20, width: 100, height: 50)
		stopButton?.addTarget(self, action: #selector(_stopTapped), for: .touchUpInside)
		self.view.addSubview(stopButton!)
		
		stopButton?.backgroundColor = UIColor.purple
		stopButton?.layer.borderColor = UIColor.orange.cgColor
		stopButton?.layer.borderWidth = 0.5
		stopButton?.layer.cornerRadius = 10.0
		
		
		procButton = UIButton(type: UIButtonType.system)
		procButton?.setTitle("proc", for: UIControlState.normal)
		procButton?.frame = CGRect(x: 450, y: 20, width: 100, height: 50)
		procButton?.addTarget(self, action: #selector(_procTapped), for: .touchUpInside)
		self.view.addSubview(procButton!)
		
		testButton = UIButton(type: UIButtonType.system)
		testButton?.setTitle("TEST", for: UIControlState.normal)
		testButton?.frame = CGRect(x: 650, y: 20, width: 100, height: 50)
		testButton?.addTarget(self, action: #selector(_testTapped), for: .touchUpInside)
		self.view.addSubview(testButton!)

	}
	
	@objc private func _playTapped(sender: UIButton!) {
		print("play")
		var s:String = "to test fd 0.01 end"
		s = s + "to setup-rabbit rt 45 activate-daemon daemon-rabbit-eat activate-daemon daemon-rabbit-walk end"
		s = s + "to setup-robot set-var age 0 activate-daemon daemon-robot-walk end"
		s = s + "to setup-patch set-var grass 0.3 activate-daemon daemon-patch-grow end"
		s = s + "to daemon-robot-walk test rt 0.05 end"
		s = s + "to daemon-rabbit-walk fd 0.02 rt 0.05 end"
		s = s + "to daemon-rabbit-eat set-patch-var grass 0 end"
		s = s + "to daemon-patch-grow set-var grass (get-var grass + 0.01) end"
		store.dispatch(SetScriptAction(script: s))
		store.dispatch(SetStatusAction(status: "running"))
	}
	
	@objc private func _stopTapped(sender: UIButton!) {
		store.dispatch(SetStatusAction(status: "stopped"))
	}
	
	@objc private func _testTapped(sender: UIButton!) {
		print("TEST")
	}
	
	@objc private func _procTapped(sender: UIButton!) {
		
	}

}


extension ControlsViewController: StoreSubscriber {
	typealias StoreSubscriberStateType = RunningState
	
	func newState(state: RunningState) {
		print(state)
		self.playButton?.isEnabled = (state.s == "stopped")
		self.stopButton?.isEnabled = (state.s == "running")
	}
}

	
