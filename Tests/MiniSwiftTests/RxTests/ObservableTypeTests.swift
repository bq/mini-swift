//
//  ObservableTypeTests.swift
//  MiniSwiftTests
//
//  Created by Jorge Revuelta on 17/09/2019.
//

@testable import Mini
import Nimble
import RxBlocking
import RxSwift
import RxTest
import XCTest

private func matchPromiseHash<K: Hashable, Type: Equatable>(_ by: [K: Promise<Type>]) -> Predicate<[K: Promise<Type>]> {
    return Predicate { expression in
        guard let dict = try expression.evaluate() else {
            return PredicateResult(status: .fail,
                                   message: .fail("failed evaluating expression"))
        }
        guard dict == by else {
            return PredicateResult(status: .fail,
                                   message: .fail("Dictionary doesn't match"))
        }
        return PredicateResult(status: .matches,
                               message: .expectedTo("expectation fulfilled"))
    }
}

final class ObservableTypeTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    func test_filter_one() {
        let filterOneObserver = scheduler.createObserver(Int.self)

        scheduler.createColdObservable(
            [
                .next(10, 10),
                .next(20, 20),
                .next(30, 30),
                .completed(40),
            ]
        )
        .filterOne { $0 == 20 }
        .subscribe(filterOneObserver)
        .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(filterOneObserver.events, [
            .next(20, 20),
            .completed(20),
        ])
    }

    func test_dispatch_action_from_store() throws {
        let dispatcher = Dispatcher()
        var cancelableBag = CancelableBag()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))

        store
            .reducerGroup
            .cancelled(by: &cancelableBag)

        guard let state = try Observable<Store<TestState, TestStoreController>>
            .dispatch(using: dispatcher,
                      factory: SetCounterAction(counter: 1),
                      taskMap: { $0.counter },
                      on: store)
            .toBlocking(timeout: 5.0).first()
        else {
            fatalError()
        }

        XCTAssertTrue(state.counter.isResolved)
        XCTAssertTrue(state.counter.error == nil)
        XCTAssertEqual(state.counter.value, 1)
    }

    func test_dispatch_hashable_action_from_store() throws {
        let dispatcher = Dispatcher()
        var cancelableBag = CancelableBag()
        let store = Store<TestState, TestStoreController>(TestState(), dispatcher: dispatcher, storeController: TestStoreController(dispatcher: dispatcher))

        store
            .reducerGroup
            .cancelled(by: &cancelableBag)

        guard let state = try Observable<Store<TestState, TestStoreController>>
            .dispatch(using: dispatcher,
                      factory: SetCounterHashAction(counter: 1, key: "hello"),
                      key: "hello",
                      taskMap: { $0.hashCounter },
                      on: store)
            .toBlocking(timeout: 5.0).first()
        else {
            fatalError()
        }

        XCTAssertTrue(state.hashCounter[promise: "hello"].isResolved)
        XCTAssertTrue(state.hashCounter[promise: "hello"].error == nil)
        expect(state.hashCounter).to(matchPromiseHash(["hello": Promise<Int>.value(1)]))
    }
}
