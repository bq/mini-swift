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

//MARK: - TODO: Translate to Combine if needed
/*
import Foundation
import RxSwift

public enum Promises {}

public extension Promises {
    enum Lifetime {
        case once
        case forever(ignoringOld: Bool = false)
    }
}

extension ObservableType where Self.Element: StateType {
    private func filterForLifetime<Type>(
        taskMap: @escaping ((Self.Element) -> Promise<Type>?),
        lifetime: Promises.Lifetime
    ) -> Observable<Element> {
        switch lifetime {
        case .once:
            return filterOne { taskMap($0)?.isResolved ?? true }
        case let .forever(ignoreOld):
            let date = Date()
            return skipWhile {
                if ignoreOld {
                    if let promise = taskMap($0), let promiseDate: Date = promise.date {
                        return promiseDate < date
                    }
                    return false
                } else {
                    return false
                }
            }
            .filter { taskMap($0)?.isResolved ?? true }
        }
    }

    private func filterForKeyedLifetime<K: Hashable, Type>(
        key: K,
        taskMap: @escaping ((Self.Element) -> [K: Promise<Type>]),
        lifetime: Promises.Lifetime
    ) -> Observable<Element> {
        switch lifetime {
        case .once:
            return filter { taskMap($0).hasValue(for: key) }
                .filter { taskMap($0)[promise: key].isResolved }
        case .forever:
            return skipWhile { taskMap($0)[promise: key].isPending || taskMap($0)[promise: key].isResolved }
                .filter { taskMap($0).hasValue(for: key) }
                .filter { taskMap($0)[promise: key].isResolved }
                .take(1)
        }
    }

    private func subscribe<Type>(
        taskMap: @escaping ((Self.Element) -> Promise<Type>?),
        lifetime: Promises.Lifetime = .once,
        success: @escaping (Self.Element) -> Void = { _ in },
        error: @escaping (Self.Element) -> Void = { _ in }
    )
        -> Disposable {
        return filterForLifetime(taskMap: taskMap, lifetime: lifetime)
            .subscribe(onNext: { state in
                if let promise = taskMap(state) {
                    if case .success? = promise.result {
                        success(state)
                    }
                    if case .failure? = promise.result {
                        error(state)
                    }
                }
            })
    }

    private func subscribe<K: Hashable, Type>(
        key: K,
        taskMap: @escaping ((Self.Element) -> [K: Promise<Type>]),
        lifetime: Promises.Lifetime = .once,
        success: @escaping (Self.Element) -> Void = { _ in },
        error: @escaping (Self.Element) -> Void = { _ in }
    )
        -> Disposable {
        return filterForKeyedLifetime(key: key, taskMap: taskMap, lifetime: lifetime)
            .subscribe(onNext: { state in
                let promise = taskMap(state)[promise: key]
                if case .success? = promise.result {
                    success(state)
                }
                if case .failure? = promise.result {
                    error(state)
                }
            })
    }
}

extension ObservableType where Element: StoreType & ObservableType, Self.Element.State == Self.Element.Element {
    @available(*, deprecated, message: "Use store.dispatch() or dispatcher.dispatch in conjunction with an Observable over the Store: withStateChanges, select")
    public static func dispatch<A: Action, Type, T: Promise<Type>>(
        using dispatcher: Dispatcher? = nil,
        factory action: @autoclosure @escaping () -> A,
        taskMap: @escaping (Self.Element.State) -> T?,
        on store: Self.Element,
        lifetime: Promises.Lifetime = .once
    )
        -> Observable<Self.Element.State> {
        let observable: Observable<Self.Element.State> = Observable.create { observer in
            let action = action()
            let dispatcher = dispatcher ?? store.dispatcher
            dispatcher.dispatch(action, mode: .sync)
            let subscription = store.subscribe(
                taskMap: taskMap,
                lifetime: lifetime,
                success: { state in
                    observer.on(.next(state))
                },
                error: { state in
                    if let task = taskMap(state), let error = task.error {
                        observer.on(.error(error))
                    }
                }
            )
            return Disposables.create([subscription])
        }
        return observable
    }

    @available(*, deprecated, message: "Use store.dispatch() or dispatcher.dispatch in conjunction with an Observable over the Store: withStateChanges, select")
    public static func dispatch<A: Action, K: Hashable, Type, T: Promise<Type>>(
        using dispatcher: Dispatcher? = nil,
        factory action: @autoclosure @escaping () -> A,
        key: K,
        taskMap: @escaping (Self.Element.State) -> [K: T],
        on store: Self.Element,
        lifetime: Promises.Lifetime = .once
    )
        -> Observable<Self.Element.State> {
        let observable: Observable<Self.Element.State> = Observable.create { observer in
            let dispatcher = dispatcher ?? store.dispatcher
            let action = action()
            dispatcher.dispatch(action, mode: .sync)
            let subscription = store.subscribe(
                key: key,
                taskMap: taskMap,
                lifetime: lifetime,
                success: { state in
                    observer.on(.next(state))
                },
                error: { state in
                    if let task = taskMap(state)[key], let error = task.error {
                        observer.on(.error(error))
                    }
                }
            )
            return Disposables.create([subscription])
        }
        return observable
    }
}*/
