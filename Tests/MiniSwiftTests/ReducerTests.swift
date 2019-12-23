@testable import Mini
import Nimble
import RxSwift
import XCTest

final class ReducerTests: XCTestCase {
    func test_dispatcher_triggers_action_in_reducer_group_reducer() {
        var cancelableBag = CancelableBag()
        let dBag = DisposeBag()
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        store
            .reducerGroup
            .cancelled(by: &cancelableBag)
        XCTAssertTrue(store.state.counter.isIdle)
        var counter: Int = 0
        store
            .map { $0.counter.value }
            .filter { $0 != nil }
            .subscribe(onNext: { _counter in
                counter = _counter!
            })
            .disposed(by: dBag)
        dispatcher.dispatch(
            SetCounterAction(counter: 1),
            mode: .sync
        )
        expect(counter).toEventually(equal(1), timeout: 5.5, pollInterval: 0.2)
    }

    func test_no_subscribe_to_store_produces_no_changes() {
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        XCTAssertTrue(store.state.counter.isIdle)
        dispatcher.dispatch(
            SetCounterAction(counter: 2),
            mode: .sync
        )
        XCTAssertTrue(store.state.counter.isIdle)
    }

    func test_subscribe_to_store_receive_actions() {
        let dBag = DisposeBag()
        var cancelableBag = CancelableBag()
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        XCTAssertTrue(store.state.counter.isIdle)
        var counter: Int = 0
        store
            .map { $0.counter.value }
            .filter { $0 != nil }
            .subscribe(onNext: { _counter in
                counter = _counter!
            })
            .disposed(by: dBag)
        store
            .reducerGroup
            .cancelled(by: &cancelableBag)
        dispatcher.dispatch(
            SetCounterAction(counter: 2),
            mode: .sync
        )
        expect(counter).toEventually(equal(2), timeout: 5.5, pollInterval: 0.2)
    }

    func test_subscribe_to_store_receive_multiple_actions() {
        let dBag = DisposeBag()
        var cancelableBag = CancelableBag()
        let dispatcher = Dispatcher()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        XCTAssertTrue(store.state.counter.isIdle)
        var counter: Int = 0
        store
            .map { $0.counter.value }
            .filter { $0 != nil }
            .subscribe(onNext: { _counter in
                counter = _counter!
            })
            .disposed(by: dBag)
        store
            .reducerGroup
            .cancelled(by: &cancelableBag)
        dispatcher.dispatch(
            SetCounterAction(counter: 2),
            mode: .sync
        )
        expect(counter).toEventually(equal(2), timeout: 5.5, pollInterval: 0.2)
        dispatcher.dispatch(
            SetCounterAction(counter: 3),
            mode: .sync
        )
        expect(counter).toEventually(equal(3), timeout: 5.5, pollInterval: 0.2)
    }

    func test_reset_state() {
        let dBag = DisposeBag()
        var cancelableBag = CancelableBag()
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        XCTAssertTrue(store.state.counter.isIdle)
        var counter: Int = 0
        store
            .map { $0.counter.value }
            .filter { $0 != nil }
            .subscribe(onNext: { _counter in
                counter = _counter!
            })
            .disposed(by: dBag)
        store
            .reducerGroup
            .cancelled(by: &cancelableBag)
        dispatcher.dispatch(
            SetCounterAction(counter: 3),
            mode: .sync
        )
        expect(counter).toEventually(equal(3), timeout: 5.5, pollInterval: 0.2)
        store.reset()
        XCTAssert(store.state.isEqual(to: initialState))
    }

    func test_state_received_in_store() throws {
        let dBag = DisposeBag()
        var cancelableBag = CancelableBag()
        let dispatcher = Dispatcher()
        let initialState = TestState()
        let store = Store<TestState, TestStoreController>(initialState, dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))
        XCTAssertTrue(store.state.counter.isIdle)
        var counter: Int = 0
        store
            .map { $0.counter.value }
            .filter { $0 != nil }
            .subscribe(onNext: { _counter in
                counter = _counter!
            })
            .disposed(by: dBag)
        store
            .reducerGroup
            .cancelled(by: &cancelableBag)
        dispatcher.dispatch(
            SetCounterAction(counter: 3),
            mode: .sync
        )
        expect(counter).toEventually(equal(3), timeout: 5.5, pollInterval: 0.2)
        dispatcher.dispatch(
            SetCounterAction(counter: 4),
            mode: .sync
        )
        expect(counter).toEventually(equal(4), timeout: 5.5, pollInterval: 0.2)
    }
}
