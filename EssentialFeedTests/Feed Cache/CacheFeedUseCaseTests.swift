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
    
    typealias DeletionCompletion = (Error?) -> Void
        
    private var deletionCompletions = [DeletionCompletion]()
    
    enum ReceivedMessage: Equatable {
        
        case deletion
        case insertion(items: [FeedItem], date: Date)
    }
    
    var receivedMessage = [ReceivedMessage]()
    
    func deleteCacheFeed(completion: @escaping (Error?) -> Void) {
        
        deletionCompletions.append(completion)
        receivedMessage.append(.deletion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        
        deletionCompletions[index](nil)
    }
    
    func insert(items: [FeedItem], currentDate: Date) {
        
        receivedMessage.append(.insertion(items: items, date: currentDate))
    }
}

class LocalFeedLoader {
    
    let store: FeedStore
    let items: [FeedItem]
    let currentDate: () -> Date
    
    init(store: FeedStore, items: [FeedItem], currentDate: @escaping () -> Date) {
        
        self.store = store
        self.items = items
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem]) {
        
        store.deleteCacheFeed { [unowned self] error in
            
            if error == nil {
                
                self.store.insert(items: items, currentDate: self.currentDate())
            }
        }
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreate() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_save_requestsCacheDeletion() {
        
        let (sut, store) = makeSUT()
        
        let items = [uniqueItem()]
        sut.save(items: items)
        
        XCTAssertEqual(store.receivedMessage, [.deletion])
    }
    
    func test_save_doesNotRequestCacheDeletionUponDeletionError() {
        
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        let items = [uniqueItem()]
        sut.save(items: items)
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessage, [.deletion])
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        
        let timeStamp = Date()
        
        let (sut, store) = makeSUT(currentDate: { return timeStamp })
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items: items)
        
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessage, [.deletion, .insertion(items: items, date: timeStamp)])
    }
    
    //Marker: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, items: [uniqueItem()], currentDate: currentDate)
        
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
