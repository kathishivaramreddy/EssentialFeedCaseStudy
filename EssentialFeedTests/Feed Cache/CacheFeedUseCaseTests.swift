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
    typealias InsertionCompletion = (Error?) -> Void
        
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletion = [InsertionCompletion]()
    
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
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        
        insertionCompletion[index](error)
    }
    
    func insert(items: [FeedItem], currentDate: Date, completion: @escaping (Error?) -> Void) {
        
        insertionCompletion.append(completion)
        receivedMessage.append(.insertion(items: items, date: currentDate))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        
        insertionCompletion[index](nil)
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
    
    func save(items: [FeedItem], completion: @escaping (Error?) -> ()) {
        
        store.deleteCacheFeed { [unowned self] error in
            
            
            
            if error == nil {
                
                self.store.insert(items: items, currentDate: self.currentDate()) {error in
                    
                    completion(error)
                }
            } else {
                
                completion(error)
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
        sut.save(items: items) { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.deletion])
    }
    
    func test_save_doesNotRequestCacheDeletionUponDeletionError() {
        
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        let items = [uniqueItem()]
        sut.save(items: items) { _ in }
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessage, [.deletion])
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        
        let timeStamp = Date()
        
        let (sut, store) = makeSUT(currentDate: { return timeStamp })
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items: items) { _ in }
        
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessage, [.deletion, .insertion(items: items, date: timeStamp)])
    }
    
    func test_save_failsOnDeletionError() {
        
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        let items = [uniqueItem()]
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for save completion")
        
        sut.save(items: items) { error in
            
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    func test_save_failsOnInsertionError() {
        
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        let items = [uniqueItem()]
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for save completion")
        
        sut.save(items: items) { error in
            
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, insertionError)
    }
    
    func test_save_succeedsOnSuccessfulInsertion() {
        
        let (sut, store) = makeSUT()
        
        let items = [uniqueItem()]
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for save completion")
        
        sut.save(items: items) { error in
            
            receivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNil(receivedError)
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
