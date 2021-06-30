import Foundation
import Combine

@available(iOS 13.0, *)
public protocol GroupReducer: Cancellable {
    var disposeBag: [Cancellable] { get }
}

@available(iOS 13.0, *)
public class ReducerGroup: GroupReducer {
    public var disposeBag: [Cancellable] = []

    public init(_ builder: Cancellable...) {
        let disposable = builder
        disposable.forEach { disposeBag.append($0) }
    }

    public func cancel() {
        disposeBag.forEach { $0.cancel() }
        disposeBag.removeAll()
    }
}
