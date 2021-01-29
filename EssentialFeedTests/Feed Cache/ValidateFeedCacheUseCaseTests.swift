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
    
    func test_validateCache_doesNotDeleteCacheOnLessThanSevenDayCache() {
        
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.validateCache()
        
        let lessThanSevenDays = currentDate.adding(days: -7).adding(seconds: 1)
        
        store.completeRetrievalWith(localFeed: uniqueItems().localItems, timeStamp: lessThanSevenDays)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_validateCache_deletesSevenDaysOldCache() {
        
        let currentDate = Date()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        sut.validateCache()
        
        let sevenDays = currentDate.adding(days: -7)
        
        store.completeRetrievalWith(localFeed: uniqueItems().localItems, timeStamp: sevenDays)
        
        XCTAssertEqual(store.receivedMessage, [.retrieve, .deletion])
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
