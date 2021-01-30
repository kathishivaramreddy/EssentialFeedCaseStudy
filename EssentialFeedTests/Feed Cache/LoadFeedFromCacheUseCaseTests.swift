//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 28/01/21.
//

import Foundation
import XCTest

import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotRecieveMessage() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_load_requestCacheRetreiva() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_deliverErrorOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, withCompletion: .failure(retrievalError)) {
            
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliverEmptyCacheOnEmptyCacheAndSuccessfulRetrieval() {

        let (sut, store) = makeSUT()
        
        expect(sut, withCompletion: .success([])) {
            
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliverCacheImageOnNonExpiredCache() {
        
        let currentDate = Date()
        
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        let feed = uniqueItems()
        
        let nonExpiredCache = currentDate.minusMaxFeedCacheAge().adding(seconds: 1)
        expect(sut, withCompletion: .success(feed.models)) {
            
            store.completeRetrievalWith(localFeed: feed.localItems, timeStamp: nonExpiredCache)
        }
    }
    
    func test_load_deliverErrorImageOnExpirationCache() {
        
        let currentDate = Date()
        
        let (sut, store) = makeSUT(currentDate: { currentDate })

        let feed = uniqueItems()
            
        let onExpirateCacheDay = currentDate.minusMaxFeedCacheAge()
        expect(sut, withCompletion: .success([])) {
            
            store.completeRetrievalWith(localFeed: feed.localItems, timeStamp: onExpirateCacheDay)
        }
    }
    
    func test_load_deliverEmptyImageOnExpiredCache() {
        
        let currentDate = Date()
        
        let (sut, store) = makeSUT(currentDate: { currentDate })

        let feed = uniqueItems()
            
        let expiredCache = currentDate.minusMaxFeedCacheAge().adding(seconds: -1)
        expect(sut, withCompletion: .success([])) {
            
            store.completeRetrievalWith(localFeed: feed.localItems, timeStamp: expiredCache)
        }
    }
    
    func test_load_doesNotHaveSideEffectOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
        
    }
    
    func test_load_doesNotHaveSideEffectOnOnEmptyCache() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_doesNotHaveSideEffectOnNonExpiredCache() {
        
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.load { _ in }
        
        let nonExpiredCache = currentDate.minusMaxFeedCacheAge().adding(seconds: 1)
        
        store.completeRetrievalWith(localFeed: uniqueItems().localItems, timeStamp: nonExpiredCache)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_doesNotHaveSideEffectOnExpirationCache() {
        
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.load { _ in }
        
        let expirationCache = currentDate.minusMaxFeedCacheAge()
        
        store.completeRetrievalWith(localFeed: uniqueItems().localItems, timeStamp: expirationCache)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_deleteExpiredCache() {
        
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.load { _ in }
        
        let expiredCache = currentDate.minusMaxFeedCacheAge().adding(seconds: -1)
        
        store.completeRetrievalWith(localFeed: uniqueItems().localItems, timeStamp: expiredCache)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSutIsDeallocated() {
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.LoadResult]()
        sut?.load { receivedResult.append($0) }
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    //Marker: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackMemoryLeak(sut, file: file, line: line)
        trackMemoryLeak(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, withCompletion expectedResult: LoadFeedResult, action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Expectation for load")

        sut.load { receivedResult in

            switch (receivedResult, expectedResult) {
                case let (.success(receivedImages), .success(expectedImages)):
                    XCTAssertEqual(receivedImages, expectedImages,file: file, line: line)
                case let (.failure(receivedError), .failure(expectedError)):
                    XCTAssertEqual(receivedError as NSError, expectedError as NSError,file: file, line: line)
                default:
                    XCTFail("Expected \(expectedResult) but got \(receivedResult)",file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
