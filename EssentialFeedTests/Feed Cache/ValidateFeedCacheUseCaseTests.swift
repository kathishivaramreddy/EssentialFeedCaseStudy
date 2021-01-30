//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 29/01/21.
//

import Foundation
import XCTest

import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotRecieveMessage() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .deletion])
        
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteCacheOnNonExpirationCache() {
        
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.validateCache()
        
        let nonExpiredCache = currentDate.minusMaxFeedCacheAge().adding(seconds: 1)
        
        store.completeRetrievalWith(localFeed: uniqueItems().localItems, timeStamp: nonExpiredCache)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_validateCache_deletesExpirationCache() {
        
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.validateCache()
        
        let expirationCache = currentDate.minusMaxFeedCacheAge()
        
        store.completeRetrievalWith(localFeed: uniqueItems().localItems, timeStamp: expirationCache)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .deletion])
    }
    
    func test_validateCache_doesNotdeletesInvalidCacheAfterSUTInstanceHasBeenDeleted() {
        
        let currentDate = Date()
        let store = FeedStoreSpy()
        
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { currentDate })
        
        sut?.validateCache()
        
        let sevenDays = currentDate.minusMaxFeedCacheAge()
        sut = nil
        
        store.completeRetrievalWith(localFeed: uniqueItems().localItems, timeStamp: sevenDays)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    //Marker: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackMemoryLeak(sut, file: file, line: line)
        trackMemoryLeak(store, file: file, line: line)
        
        return (sut, store)
    }
}
