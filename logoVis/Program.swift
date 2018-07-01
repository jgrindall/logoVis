import UIKit
import JavaScriptCore
import WebKit

class Program {
	
	public var receive: ((_ s:String, _ f:Float) -> Void)?
	private var item: DispatchWorkItem!
	private var _cancelled:Bool = false
	
	public func cancel(){
		print("Cancel")
		print(item)
		_cancelled = true
		item?.cancel()
	}
	
	public func start(tree:JSON, targets:[Target], patches:[Patch]){
		_cancelled = false
		let queue = DispatchQueue.global()
		item = DispatchWorkItem { [weak self] in
			let v:Visitor = Visitor()
			v.receive = {
				(s:String, f:Float) -> Void in
				self?.receive!(s, f)
			}
			v.isActive = {
				return !(self!._cancelled || (self?.item.isCancelled)!)
			}
			v.start(tree: tree, targets:targets, patches:patches)
		}
		queue.async(execute: item)
	}

}


