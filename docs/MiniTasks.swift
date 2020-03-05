import Foundation
import Mini
import RxSwift
import SwiftOnoneSupport

public typealias AnyTask = MiniTasks.TypedTask<Any>

public protocol CompletableAction: Mini.Action, MiniTasks.PayloadAction {}

public protocol EmptyAction: Mini.Action, MiniTasks.PayloadAction where Self.Payload == Never {
    init(task: MiniTasks.AnyTask)
}

extension EmptyAction {
    public init(task _: MiniTasks.AnyTask, payload _: Self.Payload?)
}

public protocol KeyedCompletableAction: Mini.Action, MiniTasks.KeyedPayloadAction {}

public protocol KeyedPayloadAction {
    associatedtype Payload

    associatedtype Key: Hashable

    init(task: MiniTasks.AnyTask, payload: Self.Payload?, key: Self.Key)
}

public typealias KeyedTask<K> = [K: MiniTasks.AnyTask] where K: Hashable

public protocol PayloadAction {
    associatedtype Payload

    init(task: MiniTasks.AnyTask, payload: Self.Payload?)
}

@dynamicMemberLookup public class TypedTask<T>: Equatable {
    public enum Status {
        case idle

        case running

        case success

        case error
    }

    public let status: MiniTasks.TypedTask<T>.Status

    public let data: T?

    public let error: Error?

    public let initDate: Date

    public init(status: MiniTasks.TypedTask<T>.Status = .idle, data: T? = nil, error: Error? = nil)

    public static func idle() -> MiniTasks.AnyTask

    public static func running() -> MiniTasks.AnyTask

    public static func success<T>(_ data: T? = nil) -> MiniTasks.TypedTask<T>

    public static func success() -> MiniTasks.AnyTask

    public static func failure(_ error: Error) -> MiniTasks.AnyTask

    public var isRunning: Bool { get }

    public var isCompleted: Bool { get }

    public var isSuccessful: Bool { get }

    public var isFailure: Bool { get }

    public subscript<Value>(dynamicMember member: String) -> Value?

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: MiniTasks.TypedTask<T>, rhs: MiniTasks.TypedTask<T>) -> Bool
}

extension ObservableType where Self.Element: Mini.StateType {
    /**
     Maps from a `StateType` property to create an `Observable` that contains the filtered property and all its changes.
     */
    public func withStateChanges<T>(in stateComponent: KeyPath<Self.Element, T>) -> RxSwift.Observable<T>

    /**
     Maps from a `StateType` property to create an `Observable` that contains the filtered property and all its changes using a `taskComponent` (i.e. a Task component in the State) to be completed (either successfully or failed).
     */
    public func withStateChanges<T, Type, U>(in stateComponent: KeyPath<Self.Element, T>, that taskComponent: KeyPath<Self.Element, U>) -> RxSwift.Observable<T> where U: MiniTasks.TypedTask<Type>
}