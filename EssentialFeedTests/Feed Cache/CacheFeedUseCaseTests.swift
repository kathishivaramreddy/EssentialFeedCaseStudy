//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 28/01/21.
//

import Foundation
import XCTest

import EssentialFeed

class FeedStore {
    
    var deleteCacheFeedCallCount = 0
    var insertCacheFeedCallCount = 0
    
    func deleteCacheFeed() {
        
        deleteCacheFeedCallCount += 1
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0) {
        
    }
    
    func completeDeletionSuccessfully() {
        
        insertCacheFeedCallCount += 1
    }
}

class LocalFeedLoader {
    
    let store: FeedStore
    
    init(store: FeedStore) {
        
        self.store = store
    }
    
    func save(items: [FeedItem]) {
        
        store.deleteCacheFeed()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreate() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        
        let (sut, store) = makeSUT()
        
        let items = [uniqueItem()]
        sut.save(items: items)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheDeletionUponDeletionError() {
        
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        let items = [uniqueItem()]
        sut.save(items: items)
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCacheFeedCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        let items = [uniqueItem()]
        sut.save(items: items)
        
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCacheFeedCallCount, 1)
    }
    
    //Marker: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        trackMemoryLeak(sut, file: file, line: line)
        trackMemoryLeak(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
}
