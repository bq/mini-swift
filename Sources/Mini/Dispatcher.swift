/*
 Copyright [2019] [BQ]

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Dispatch
import Foundation
import NIOConcurrencyHelpers

public typealias SubscriptionMap = SharedDictionary<String, OrderedSet<WorkItem>?>

public final class Dispatcher {
    public struct DispatchMode {
        // swiftlint:disable:next type_name nesting
        public enum UI {
            case sync, async
        }
    }

    public var subscriptionCount: Int {
        return subscriptionMap.innerDictionary.mapValues { set -> Int in
            guard let setValue = set else { return 0 }
            return setValue.count
        }
        .reduce(0) { $0 + $1.value }
    }

    public static let defaultPriority = 100

    private let internalQueue = DispatchQueue(label: "MiniSwift", qos: .userInitiated)
    private var subscriptionMap = SubscriptionMap()
    private var middleware = [Middleware]()
    private var service = [Service]()
    private let root: RootChain
    private var chain: Chain
    private var dispatching: Bool = false
    private var subscriptionCounter = NIOAtomic<Int>.makeAtomic(value: 1)
    private var workItems: [(Action) -> DispatchWorkItem] = []

    public init() {
        root = RootChain(map: subscriptionMap)
        chain = root
    }

    private func build() -> Chain {
        return middleware.reduce(root) { (chain: Chain, middleware: Middleware) -> Chain in
            ForwardingChain { action in
                middleware.perform(action, chain)
            }
        }
    }

    public func add(middleware: Middleware) {
        internalQueue.sync {
            self.middleware.append(middleware)
            self.chain = build()
        }
    }

    public func remove(middleware: Middleware) {
        internalQueue.sync {
            if let index = self.middleware.firstIndex(where: { middleware.id == $0.id }) {
                self.middleware.remove(at: index)
            }
            chain = build()
        }
    }

    public func register(service: Service) {
        internalQueue.sync {
            self.service.append(service)
        }
    }

    public func unregister(service: Service) {
        internalQueue.sync {
            if let index = self.service.firstIndex(where: { service.id == $0.id }) {
                self.service.remove(at: index)
            }
        }
    }

    public func subscribe(priority _: Int, tag: String, completion: @escaping (Action) -> Void) -> WorkItem {
        let work: WorkItem = WorkItem(dispatcher: self,
                                      completion: completion,
                                      tag: tag,
                                      id: getNewSubscriptionId())
        return registerInternal(work: work)
    }

    private func registerInternal(work: WorkItem) -> WorkItem {
        internalQueue.sync {
            if let map = subscriptionMap[work.tag, orPut: OrderedSet<WorkItem>()] {
                map.insert(work)
            }
        }
        return work
    }

    fileprivate func unregisterInternal(work: WorkItem) {
        internalQueue.sync {
            var removed = false
            if let set = subscriptionMap[work.tag] as? OrderedSet<WorkItem> {
                removed = set.remove(work)
            } else {
                removed = true
            }
            assert(removed, "Failed to remove DispatcherSubscription, multiple dispose calls?")
        }
    }

    public func subscribe<T: Action>(completion: @escaping (T) -> Void) -> WorkItem {
        return subscribe(tag: T.tag, completion: { (action: T) -> Void in
            completion(action)
        })
    }

    public func subscribe<T: Action>(tag: String, completion: @escaping (T) -> Void) -> WorkItem {
        return subscribe(tag: tag, completion: { object in
            if let action = object as? T {
                completion(action)
            } else {
                fatalError("Casting to \(tag) failed")
            }
        })
    }

    public func subscribe(tag: String, completion: @escaping (Action) -> Void) -> WorkItem {
        return subscribe(priority: Dispatcher.defaultPriority, tag: tag, completion: completion)
    }

    public func dispatch(_ action: Action, mode: Dispatcher.DispatchMode.UI) {
        switch mode {
        case .sync:
            if DispatchQueue.isMain {
                dispatch(action)
            } else {
                DispatchQueue.main.sync {
                    self.dispatch(action)
                }
            }
        case .async:
            DispatchQueue.main.async {
                self.dispatch(action)
            }
        }
    }

    private func dispatch(_ action: Action) {
        assert(DispatchQueue.isMain)
        internalQueue.sync {
            defer { dispatching = false }
            if dispatching {
                preconditionFailure("Already dispatching")
            }
            dispatching = true
            _ = chain.proceed(action)
            internalQueue.async { [weak self] in
                guard let self = self else { return }
                self.service.forEach {
                    $0.perform(action, self.chain)
                }
            }
        }
    }

    private func getNewSubscriptionId() -> Int {
        return subscriptionCounter.add(1)
    }
}

public protocol Cancelable {
    func cancel()
}

public final class WorkItem: Comparable, Hashable, Cancelable {
    private let dispatcher: Dispatcher
    private let completion: (Action) -> Void
    private var workItem: ((Action) -> DispatchWorkItem)?
    fileprivate let tag: String
    private let id: Int

    public init(dispatcher: Dispatcher,
                completion: @escaping (Action) -> Void,
                tag: String,
                id: Int) {
        self.dispatcher = dispatcher
        self.completion = completion
        self.tag = tag
        self.id = id
        workItem = { action in
            DispatchWorkItem {
                completion(action)
            }
        }
    }

    public func cancel() {
        dispatcher.unregisterInternal(work: self)
    }

    public func on(_ action: Action) {
        guard let workItem = self.workItem?(action), let queue = OperationQueue.current?.underlyingQueue else { return }
        queue.async(execute: workItem)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
        hasher.combine(id)
    }

    public static func == (lhs: WorkItem, rhs: WorkItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public static func < (lhs: WorkItem, rhs: WorkItem) -> Bool {
        lhs.hashValue < rhs.hashValue
    }
}
