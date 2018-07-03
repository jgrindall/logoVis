import UIKit
import JavaScriptCore
import WebKit
import SceneKit
import ReSwift

class ViewController: UIViewController {
	
	private lazy var state1Subscriber: BlockSubscriber<RunningState> = BlockSubscriber<RunningState>(block: { runningState in
		print("runningState")
		print(runningState)
		print(self.view)
	})
	
	required init?(coder aDecoder: NSCoder) {
		super.init(nibName: nil, bundle: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		store.unsubscribe(self.state1Subscriber)
	}
	
	func _addChildController(content: UIViewController) {
		addChildViewController(content)
		self.view.addSubview(content.view)
		content.didMove(toParentViewController: self)
	}
	
	func _removeContentController(content: UIViewController) {
		content.willMove(toParentViewController: nil)
		content.view.removeFromSuperview()
		content.removeFromParentViewController()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		_addChildController(content: ControlsViewController(frame: CGRect(x: 0, y: 0, width: 800, height: 100)))
		_addChildController(content: GameViewController(frame: CGRect(x: 0, y: 100, width: 800, height: 600)))
		store.subscribe(self.state1Subscriber) { state in
			state.select { state in state.runningState }
		}
		
	}
	
	override var prefersStatusBarHidden : Bool {
		return true
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

