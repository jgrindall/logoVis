import ReSwift

func runningReducer(action: Action, state: RunningState?) ->RunningState {
	let state = state ?? RunningState(s: "stopped")
	print(state, action)
	switch action {
	case let a as SetStatusAction:
		if(a.status == "running"){
			return RunningState(s: "running")
		}
		else if(a.status == "stopped"){
			return RunningState(s: "stopped")
		}
	default: break
	}
	return state
}

func scriptReducer(action: Action, state: ScriptState?) ->ScriptState {
	let state = state ?? ScriptState(s: "")
	print(state, action)
	switch action {
	case let a as SetScriptAction:
		return ScriptState(s: a.script)
	default: break
	}
	return state
}

func appReducer(action: Action, state: AppState?) -> AppState {
	return AppState(
		runningState: runningReducer(action: action, state: state?.runningState),
		scriptState: scriptReducer(action: action, state: state?.scriptState)
	)
}

