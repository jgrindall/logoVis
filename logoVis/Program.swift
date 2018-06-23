import UIKit
import JavaScriptCore
import WebKit

class Program {
	
	public var receive: ((_ f:Float) -> Void)?
	private var item: DispatchWorkItem!
	private var _cancelled:Bool = false
	
	public func cancel(){
		print("Cancel")
		print(item)
		_cancelled = true
		item?.cancel()
	}
	
	public func start(tree:JSON){
		print("start")
		_cancelled = false
		let queue = DispatchQueue.global()
		item = DispatchWorkItem { [weak self] in
			print("START")
			let v:Visitor = Visitor()
			v.receive = {
				(f:Float) -> Void in
				print("cb", f)
				self?.receive!(f)
			}
			v.isCancelled = {
				print("cancelled?", self?._cancelled, self?.item.isCancelled)
				return (self!._cancelled || (self?.item.isCancelled)!)
			}
			v.start(tree: tree)
		}
		queue.async(execute: item)
	}

}


