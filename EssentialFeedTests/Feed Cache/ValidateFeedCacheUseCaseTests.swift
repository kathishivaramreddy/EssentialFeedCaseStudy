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
    
    //Marker: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackMemoryLeak(sut, file: file, line: line)
        trackMemoryLeak(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func uniqueItems() -> (models: [FeedImage], localItems: [LocalFeedImage]) {
        
        let items = [uniqueItem(), uniqueItem()]
        let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
        
        return (items, localItems)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
}
