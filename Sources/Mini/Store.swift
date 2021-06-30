import Combine
import Foundation

@available(iOS 13.0, *)
public class Store<State: ObservableObject, StoreController: Cancellable>: ObservableObject {

    public typealias State = State
    public typealias StoreController = StoreController

    public let dispatcher: Dispatcher
    public var storeController: StoreController
    public var state: State {
        didSet {
            objectWillChange.send()
        }
    }
    
    public var reducerGroup: ReducerGroup {
        return ReducerGroup()
    }

    public init(state: State,
                dispatcher: Dispatcher,
                storeController: StoreController) {
        self.dispatcher = dispatcher
        self.state = state
        self.storeController = storeController
    }
}

