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
    
    func deleteCacheFeed() {
        
        deleteCacheFeedCallCount += 1
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
        
        let store = FeedStore()
        
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        
        let store = FeedStore()
        
        let sut = LocalFeedLoader(store: store)
        
        let items = [uniqueItem()]
        sut.save(items: items)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }
    
    //Marker: Helpers
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}
