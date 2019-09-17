//
//  PromiseTests.swift
//  MiniSwift
//
//  Created by Jorge Revuelta on 11/09/2019.
//

import XCTest
@testable import MiniSwift

class PromiseTests: XCTestCase {
    
    fileprivate enum Error: Swift.Error { case dummy }
    
    func test_is_pending() {
        XCTAssertTrue(Promise<Void>.pending().isPending)
        XCTAssertFalse(Promise().isPending)
        XCTAssertFalse(Promise<Void>(error: Error.dummy).isPending)
    }
    
    func test_is_resolved() {
        XCTAssertFalse(Promise<Void>.pending().isResolved)
        XCTAssertTrue(Promise().isResolved)
        XCTAssertTrue(Promise<Void>(error: Error.dummy).isResolved)
    }
    
    func test_is_fulfilled() {
        XCTAssertFalse(Promise<Void>.pending().isFulfilled)
        XCTAssertTrue(Promise().isFulfilled)
        XCTAssertFalse(Promise<Void>(error: Error.dummy).isFulfilled)
    }
    
    func test_is_rejected() {
        XCTAssertFalse(Promise<Void>.pending().isRejected)
        XCTAssertTrue(Promise<Void>(error: Error.dummy).isRejected)
        XCTAssertFalse(Promise().isRejected)
    }
    
    func test_fulfill() {
        let promise: Promise<Int> = Promise<Int>()
        
        XCTAssertFalse(promise.isFulfilled)
        
        promise.fulfill(1)
        
        XCTAssertTrue(promise.value! == 1)
        
        XCTAssertTrue(promise.isFulfilled)
        XCTAssertFalse(promise.isRejected)
        XCTAssertTrue(promise.isResolved)
        XCTAssertFalse(promise.isPending)
        
        if case .failure? = promise.result {
            XCTFail()
        }
    }
    
    func test_reject() {
        let promise: Promise<Int> = Promise<Int>()
        
        XCTAssertFalse(promise.isFulfilled)
        
        promise.reject(Error.dummy)
        
        XCTAssertTrue(promise.isRejected)
        XCTAssertFalse(promise.isFulfilled)
        XCTAssertTrue(promise.isResolved)
        XCTAssertFalse(promise.isPending)
        
        if case .success? = promise.result {
            XCTFail()
        }
    }
    
    func test_immutability() {
        let promise: Promise<Int> = Promise<Int>()
        
        XCTAssertFalse(promise.isFulfilled)
        
        promise.fulfill(1)
        
        XCTAssertTrue(promise.value! == 1)
        
        XCTAssertTrue(promise.isFulfilled)
        XCTAssertFalse(promise.isRejected)
        XCTAssertTrue(promise.isResolved)
        XCTAssertFalse(promise.isPending)
        
        promise.fulfill(2)
        
        XCTAssertFalse(promise.value! == 2)
    }
    
    func test_equality_with_value() {
        
        let promise1: Promise<Int> = .value(1)
        let promise2: Promise<Int> = .value(2)
        
        XCTAssertFalse(promise1 == promise2)
        
    }
    
    func test_equality_pending() {
        
        let promise1: Promise<Int> = .pending()
        let promise2: Promise<Int> = .pending()
        
        XCTAssertTrue(promise1 == promise2)
        
    }
    
    func test_equality_error() {
        
        let promise1: Promise<Int> = .init(error: Error.dummy)
        let promise2: Promise<Int> = .init(error: Error.dummy)
        
        XCTAssertTrue(promise1 == promise2)
    }
}