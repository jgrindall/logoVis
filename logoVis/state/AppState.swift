
import UIKit
import SceneKit
import QuartzCore
import JavaScriptCore
import ReSwift

import ReSwift

struct MyState: StateType {
	var s: String
	init(s: String = "home") {
		self.s = s
	}
}

struct AppState: StateType {
	let routingState: MyState
}
