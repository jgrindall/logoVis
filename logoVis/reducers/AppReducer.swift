import ReSwift

func routingReducer(action: Action, state: MyState?) -> MyState {
	let state = state ?? MyState(s: "456")
	switch action {
	case let a as StatusAction:
		print(a)
		return MyState(s: "768")
	default: break
	}
	return state
}

func appReducer(action: Action, state: AppState?) -> AppState {
	return AppState(
		routingState: routingReducer(action: action, state: state?.routingState)
	)
}

