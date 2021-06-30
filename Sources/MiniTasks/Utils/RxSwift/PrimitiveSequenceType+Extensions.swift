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
<<<<

public extension PrimitiveSequenceType where Self: ObservableConvertibleType, Self.Trait == SingleTrait {
    /**
     Dispatches an given action from the result of the `Single` trait. This is only usable when the `Action` is a `CompletableAction`.
     - Parameter action: The `CompletableAction` type to be dispatched.
     - Parameter dispatcher: The `Dispatcher` object that will dispatch the action.
     - Parameter mode: The `Dispatcher` dispatch mode, `.async` by default.
     - Parameter fillOnError: The payload that will replace the action's payload in case of failure.
     */
    func dispatch<A: CompletableAction>(action: A.Type,
                                        on dispatcher: Dispatcher,
                                        mode: Dispatcher.DispatchMode.UI = .async,
                                        fillOnError errorPayload: A.Payload? = nil)
        -> Disposable where A.Payload == Self.Element {
        let subscription = subscribe(
            onSuccess: { payload in
                let action = A(task: .success(), payload: payload)
                dispatcher.dispatch(action, mode: mode)
            },
            onError: { error in
                var action: A
                if let errorPayload = errorPayload {
                    action = A(task: .success(), payload: errorPayload)
                } else {
                    action = A(task: .failure(error), payload: errorPayload)
                }
                dispatcher.dispatch(action, mode: mode)
            }
        )
        return subscription
    }

    /**
     Dispatches an given action from the result of the `Single` trait. This is only usable when the `Action` is a `CompletableAction`.
     - Parameter action: The `CompletableAction` type to be dispatched.
     - Parameter key: The key associated with the `Task` result.
     - Parameter dispatcher: The `Dispatcher` object that will dispatch the action.
     - Parameter mode: The `Dispatcher` dispatch mode, `.async` by default.
     - Parameter fillOnError: The payload that will replace the action's payload in case of failure or `nil`.
     */
    func dispatch<A: KeyedCompletableAction>(action: A.Type,
                                             key: A.Key,
                                             on dispatcher: Dispatcher,
                                             mode: Dispatcher.DispatchMode.UI = .async,
                                             fillOnError errorPayload: A.Payload? = nil)
        -> Disposable where A.Payload == Self.Element {
        let subscription = subscribe(
            onSuccess: { payload in
                let action = A(task: .success(), payload: payload, key: key)
                dispatcher.dispatch(action, mode: mode)
            },
            onError: { error in
                var action: A
                if let errorPayload = errorPayload {
                    action = A(task: .success(), payload: errorPayload, key: key)
                } else {
                    action = A(task: .failure(error), payload: errorPayload, key: key)
                }
                dispatcher.dispatch(action, mode: mode)
            }
        )
        return subscription
    }

    /**
     Builds a `CompletableAction` from a `Single`
     - Parameter action: The `CompletableAction` type to be built.
     - Parameter fillOnError: The payload that will replace the action's payload in case of failure or `nil`.
     - Returns: A `Single` of the `CompletableAction` type declared by the action parameter.
     */
    func action<A: CompletableAction>(_ action: A.Type,
                                      fillOnError errorPayload: A.Payload? = nil)
        -> Single<A> where A.Payload == Self.Element {
        return Single<A>.create { single in
            let subscription = self.subscribe(
                onSuccess: { payload in
                    let action = A(task: .success(), payload: payload)
                    single(.success(action))
                },
                onError: { error in
                    var action: A
                    if let errorPayload = errorPayload {
                        action = A(task: .success(), payload: errorPayload)
                    } else {
                        action = A(task: .failure(error), payload: errorPayload)
                    }
                    single(.success(action))
                }
            )
            return Disposables.create([subscription])
        }
    }
}

public extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Swift.Never {
    /**
     Dispatches an given action from the result of the `Completable` trait. This is only usable when the `Action` is an `EmptyAction`.
     - Parameter action: The `CompletableAction` type to be dispatched.
     - Parameter dispatcher: The `Dispatcher` object that will dispatch the action.
     - Parameter mode: The `Dispatcher` dispatch mode, `.async` by default.
     */
    func dispatch<A: EmptyAction>(action: A.Type,
                                  on dispatcher: Dispatcher,
                                  mode: Dispatcher.DispatchMode.UI = .async)
        -> Disposable {
        let subscription = subscribe { completable in
            switch completable {
            case .completed:
                let action = A(task: .success())
                dispatcher.dispatch(action, mode: mode)
            case let .error(error):
                let action = A(task: .failure(error))
                dispatcher.dispatch(action, mode: mode)
            }
        }
        return subscription
    }

    /**
     Builds an `EmptyAction` from a `Completable`
     - Parameter action: The `EmptyAction` type to be built.
     - Returns: A `Single` of the `EmptyAction` type declared by the action parameter.
     */
    func action<A: EmptyAction>(_ action: A.Type)
        -> Single<A> {
        return Single.create { single in
            let subscription = self.subscribe { event in
                switch event {
                case .completed:
                    let action = A(task: .success())
                    single(.success(action))
                case let .error(error):
                    let action = A(task: .failure(error))
                    single(.success(action))
                }
            }
            return Disposables.create([subscription])
        }
    }
}*/
