@testable import Mini
import Nimble
import RxSwift
@testable import TestMiddleware
import XCTest

final class DispatcherTests: XCTestCase {
    func test_subscription_count() {
        let dispatcher = Dispatcher()
        var disposable = CancelableBag()

        XCTAssert(dispatcher.subscriptionCount == 0)

        disposable.append(dispatcher.subscribe { (_: SetCounterActionLoaded) -> Void in })
        disposable.append(dispatcher.subscribe { (_: SetCounterActionLoaded) -> Void in })

        expect(dispatcher.subscriptionCount).toEventually(equal(2))

        disposable.forEach { $0.cancel() }

        expect(dispatcher.subscriptionCount).toEventually(equal(0))
    }

    func test_add_remove_middleware() {
        let dispatcher = Dispatcher()

        let middleware = TestMiddleware()

        dispatcher.add(middleware: middleware)

        dispatcher.dispatch(SetCounterActionLoaded(counter: .value(0)), mode: .sync)

        XCTAssert(middleware.actions(of: SetCounterActionLoaded.self).isEmpty == false)

        middleware.clear()

        XCTAssert(middleware.actions(of: SetCounterActionLoaded.self).isEmpty == true)

        dispatcher.remove(middleware: middleware)

        dispatcher.dispatch(SetCounterActionLoaded(counter: .value(0)), mode: .sync)

        XCTAssert(middleware.actions(of: SetCounterActionLoaded.self).isEmpty == true)
    }

    func test_add_remove_service() {
        class TestService: Service {
            var id: UUID = UUID()

            var actions = [Action]()

            private let expectation: XCTestExpectation

            init(_ expectation: XCTestExpectation) {
                self.expectation = expectation
            }

            var perform: ServiceChain {
                return { action, _ -> Void in
                    self.actions.append(action)
                    self.expectation.fulfill()
                }
            }
        }

        let expectation = XCTestExpectation(description: "Service")

        let dispatcher = Dispatcher()

        let service = TestService(expectation)

        dispatcher.register(service: service)

        XCTAssert(service.actions.isEmpty == true)

        dispatcher.dispatch(SetCounterActionLoaded(counter: .value(1)), mode: .sync)

        wait(for: [expectation], timeout: 5.0)

        XCTAssert(service.actions.count == 1)

        XCTAssert(service.actions.contains(where: { $0 is SetCounterActionLoaded }) == true)

        dispatcher.unregister(service: service)

        service.actions.removeAll()

        dispatcher.dispatch(SetCounterActionLoaded(counter: .value(1)), mode: .sync)

        XCTAssert(service.actions.isEmpty == true)
    }
}
