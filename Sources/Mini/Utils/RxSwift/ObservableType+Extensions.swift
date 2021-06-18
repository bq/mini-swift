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
import Combine

@available(iOS 13.0, *)
public extension Publisher where Output: Collection  {
    
    func filterMany(_ isIncluded: @escaping (Output.Element) -> Bool) -> AnyPublisher<[Output.Element], Failure> {
        map { $0.filter(isIncluded) }
            .eraseToAnyPublisher()
    }

    func mapMany<Result>(_ transform: @escaping (Output.Element) -> Result) -> Publishers.Map<Self, [Result]> {
        map { $0.map(transform) }
    }
    
    func filterKey(_ keyPath: KeyPath<Output.Element, Bool>) -> AnyPublisher<[Output.Element], Failure> {
        map { $0.filter(^keyPath) }
            .eraseToAnyPublisher()
    }
    
    func mapKey<T>(_ keyPath: KeyPath<Output.Element, T>) -> Publishers.Map<Self, [T]> {
        map { $0.map(^keyPath) }
    }
    
    func distinctUntilChanged(by comparator: @escaping (Output, Output) -> Bool) -> Publishers.Filter<Self> {
        var seen = [Output]()
        return filter { incoming in
            if seen.contains(where: { comparator($0, incoming) }) {
                return false
            } else {
                seen.append(incoming)
                return true
            }
        }
    }
    
    /**
     Selects a property component from an `Element` filtering `nil` and emitting only distinct contiguous elements.
     */
    func select<T: OptionalType>(_ keyPath: KeyPath<Output, T>) -> AnyPublisher<T.Wrapped, Self.Failure> where T.Wrapped: Equatable {
        map(keyPath)
            .filterNil()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

}

@available(iOS 13.0, *)
public extension Publisher where Self.Output: OptionalType {
    func filterNil() -> AnyPublisher<Self.Output.Wrapped, Self.Failure> {
        return self.flatMap { element -> AnyPublisher<Self.Output.Wrapped, Self.Failure> in
            guard let value = element.value
            else { return Empty(completeImmediately: false).setFailureType(to: Self.Failure.self).eraseToAnyPublisher() }
            return Just(value).setFailureType(to: Self.Failure.self).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}

@available(iOS 13.0, *)
public extension Publisher where Output: Hashable {
    func distinctUntilChanged() -> Publishers.Filter<Self> {
        var seen = Set<Output>()
        return filter { incoming in seen.insert(incoming).inserted }
    }
}

@available(iOS 13.0, *)
extension Publisher where Output: Collection {
    /**
     Maps from a `StateType` property to create an `Observable` that contains the filtered property and all its changes.
     */
    public func withStateChanges<T>(in stateComponent: KeyPath<Output.Element, T>, that componentProperty: KeyPath<T, Bool>) -> AnyPublisher<[T], Self.Failure> {
        return mapKey(stateComponent)
            .filterKey(componentProperty)
            .eraseToAnyPublisher()
    }
}
