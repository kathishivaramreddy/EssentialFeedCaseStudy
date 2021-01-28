//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 28/01/21.
//

import Foundation
import XCTest

import EssentialFeed

class FeedStoreSpy: FeedStore {
            
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletion = [InsertionCompletion]()
    
    enum ReceivedMessage: Equatable {
        
        case deletion
        case insertion(items: [LocalFeedItem], date: Date)
    }
    
    var receivedMessage = [ReceivedMessage]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        
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
    
    func insert(items: [LocalFeedItem], currentDate: Date, completion: @escaping InsertionCompletion) {
        
        insertionCompletion.append(completion)
        receivedMessage.append(.insertion(items: items, date: currentDate))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        
        insertionCompletion[index](nil)
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreate() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_save_requestsCacheDeletion() {
        
        let (sut, store) = makeSUT()
        
        sut.save(items: uniqueItems().models) { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.deletion])
    }
    
    func test_save_doesNotRequestCacheDeletionUponDeletionError() {
        
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(items: uniqueItems().models) { _ in }
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessage, [.deletion])
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        
        let timeStamp = Date()
        
        let (sut, store) = makeSUT(currentDate: { return timeStamp })
        let (items, localItems) = uniqueItems()
        sut.save(items: items) { _ in }
        
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessage, [.deletion, .insertion(items: localItems, date: timeStamp)])
    }
    
    func test_save_failsOnDeletionError() {
        
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError) {
            
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfulInsertion() {
        
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorWhenSUTIsDeallocated() {
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, items: [uniqueItem()], currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        
        sut?.save(items: uniqueItems().models) { receivedResult.append($0) }
        
        sut = nil
        
        store.completeDeletion(with: anyNSError())
        XCTAssertEqual(receivedResult.count, 0)
    }
    
    func test_save_doesNotDeliverInsertionErrorWhenSUTIsDeallocated() {
        
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, items: [uniqueItem()], currentDate: Date.init)
        
        var receivedResult = [LocalFeedLoader.SaveResult]()
        
        sut?.save(items: uniqueItems().models) { receivedResult.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertEqual(receivedResult.count, 0)
    }
    
    //Marker: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, items: uniqueItems().models, currentDate: currentDate)
        
        trackMemoryLeak(sut, file: file, line: line)
        trackMemoryLeak(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, action: () ->Void,file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for save completion")
        var receivedError: Error?

        sut.save(items: uniqueItems().models) { error in
            
            receivedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func uniqueItems() -> (models: [FeedItem], localItems: [LocalFeedItem]) {
        
        let items = [uniqueItem(), uniqueItem()]
        let localItems = items.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
        
        return (items, localItems)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
}
