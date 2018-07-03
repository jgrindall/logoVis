
import UIKit
import SceneKit
import QuartzCore
import JavaScriptCore
import ReSwift

import ReSwift

struct RunningState: StateType {
	var s: String
	init(s: String = "stopped") {
		self.s = s
	}
}

struct ScriptState: StateType {
	var s: String
	init(s: String = "") {
		self.s = s
	}
}

struct AppState: StateType {
	let runningState: RunningState
	let scriptState: ScriptState
}
