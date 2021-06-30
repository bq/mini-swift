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

import Foundation

public typealias MiddlewareChain = (Action, Chain) -> Action
public typealias Next = (Action) -> Action

public protocol Chain {
    var proceed: Next { get }
}

public protocol Middleware {
    var id: UUID { get }
    var perform: MiddlewareChain { get }
}

public final class ForwardingChain: Chain {
    private let next: Next

    public var proceed: Next {
        return { action in
            self.next(action)
        }
    }

    public init(next: @escaping Next) {
        self.next = next
    }
}

@available(iOS 13.0, *)
public final class RootChain: Chain {
    private let map: SubscriptionMap

    public var proceed: Next {
        return { action in
            if let set = self.map[action.innerTag] {
                set?.forEach { sub in
                    sub.on(action)
                }
            }
            return action
        }
    }

    public init(map: SubscriptionMap) {
        self.map = map
    }
}
