
import Foundation
import ReSwift

public class BlockSubscriber<S>: StoreSubscriber {
	public typealias StoreSubscriberStateType = S
	private let block: (S) -> Void
	
	public init(block: @escaping (S) -> Void) {
		self.block = block
	}
	
	public func newState(state: S) {
		self.block(state)
	}
}
