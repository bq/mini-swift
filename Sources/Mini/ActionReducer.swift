import Foundation
import Combine
/**
 The `Reducer` defines the behavior to be executed when a certain
 `Action` object is received.
 */
 @available(iOS 13.0, *)
public class Reducer<A: Action>: Cancellable {
    /// The `Action` type which the `Reducer` listens to.
    public let action: A.Type
    /// The `Dispatcher` object that sends the `Action` objects.
    public let dispatcher: Dispatcher
    /// The behavior to be executed when the `Dispatcher` sends a certain `Action`
    public let reducer: (A) -> Void

    private var disposable: Cancellable!

    /**
     Initializes a new `Reducer` object.
     - Parameter action: The `Action` type that will be listened to.
     - Parameter dispatcher: The `Dispatcher` that sends the `Action`.
     - Parameter reducer: The closure that will be executed when the `Dispatcher`
     sends the defined `Action` type.
     */
    public init(of action: A.Type, on dispatcher: Dispatcher, reducer: @escaping (A) -> Void) {
        self.action = action
        self.dispatcher = dispatcher
        self.reducer = reducer
        disposable = build()
    }

    private func build() -> Cancellable {
        let disposable = dispatcher.subscribe(tag: action.tag) {
            self.reducer($0)
        }
        return disposable
    }

    /// Dispose resource.
    public func cancel() {
        disposable.cancel()
    }
}
