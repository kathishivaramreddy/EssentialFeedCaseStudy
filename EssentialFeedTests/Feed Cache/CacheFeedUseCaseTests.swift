//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 28/01/21.
//

import Foundation
import XCTest

class FeedStore {
    
    let deleteCacheCount = 0
}

class LocalFeedLoader {
    
    let store: FeedStore
    init(store: FeedStore) {
        
        self.store = store
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreate() {
        
        let store = FeedStore()
        
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCacheCount, 0)
    }
}
