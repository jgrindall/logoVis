import UIKit
import JavaScriptCore
import WebKit
import SceneKit
import ReSwift

class ViewController: UIViewController {
	
	required init?(coder aDecoder: NSCoder) {
		super.init(nibName: nil, bundle: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		store.unsubscribe(self)
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
		_addChildController(content: ControlsViewController(frame: CGRect(x: 0, y: 0, width: 800, height: 60)))
		_addChildController(content: GameViewController(frame: CGRect(x: 0, y: 60, width: 800, height: 600)))
		store.subscribe(self) { $0.select { state in state.routingState } }
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

	
