/// *
// Copyright [2019] [BQ]
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// */

//MARK: - TODO: Translate to Combine if needed
/*
import Foundation
import RxSwift

public extension PrimitiveSequenceType where Self: ObservableConvertibleType, Self.Trait == SingleTrait {
    func dispatch<A: CompletableAction>(action: A.Type,
                                        on dispatcher: Dispatcher,
                                        mode: Dispatcher.DispatchMode.UI = .async,
                                        fillOnError errorPayload: A.Payload? = nil)
        -> Disposable where A.Payload == Self.Element {
        let subscription = subscribe(
            onSuccess: { payload in
                let action = A(promise: .value(payload))
                dispatcher.dispatch(action, mode: mode)
            },
            onError: { error in
                var action: A
                if let errorPayload = errorPayload {
                    action = A(promise: .value(errorPayload))
                } else {
                    action = A(promise: .error(error))
                }
                dispatcher.dispatch(action, mode: mode)
            }
        )
        return subscription
    }

    func dispatch<A: KeyedCompletableAction>(action: A.Type,
                                             key: A.Key,
                                             on dispatcher: Dispatcher,
                                             mode: Dispatcher.DispatchMode.UI = .async,
                                             fillOnError errorPayload: A.Payload? = nil)
        -> Disposable where A.Payload == Self.Element {
        let subscription = subscribe(
            onSuccess: { payload in
                let action = A(promise: [key: .value(payload)])
                dispatcher.dispatch(action, mode: mode)
            },
            onError: { error in
                var action: A
                if let errorPayload = errorPayload {
                    action = A(promise: [key: .value(errorPayload)])
                } else {
                    action = A(promise: [key: .error(error)])
                }
                dispatcher.dispatch(action, mode: mode)
            }
        )
        return subscription
    }

    func action<A: CompletableAction>(_ action: A.Type,
                                      fillOnError errorPayload: A.Payload? = nil)
        -> Single<A> where A.Payload == Self.Element {
        return Single<A>.create { single in
            let subscription = self.subscribe(
                onSuccess: { payload in
                    let action = A(promise: .value(payload))
                    single(.success(action))
                },
                onError: { error in
                    var action: A
                    if let errorPayload = errorPayload {
                        action = A(promise: .value(errorPayload))
                    } else {
                        action = A(promise: .error(error))
                    }
                    single(.success(action))
                }
            )
            return Disposables.create([subscription])
        }
    }
}

public extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Swift.Never {
    func dispatch<A: EmptyAction>(action: A.Type,
                                  on dispatcher: Dispatcher,
                                  mode: Dispatcher.DispatchMode.UI = .async)
        -> Disposable {
        let subscription = subscribe { completable in
            switch completable {
            case .completed:
                let action = A(promise: .empty())
                dispatcher.dispatch(action, mode: mode)
            case let .error(error):
                let action = A(promise: .error(error))
                dispatcher.dispatch(action, mode: mode)
            }
        }
        return subscription
    }

    func action<A: EmptyAction>(_ action: A.Type)
        -> Single<A> {
        return Single.create { single in
            let subscription = self.subscribe { event in
                switch event {
                case .completed:
                    let action = A(promise: .empty())
                    single(.success(action))
                case let .error(error):
                    let action = A(promise: .error(error))
                    single(.success(action))
                }
            }
            return Disposables.create([subscription])
        }
    }
}*/
