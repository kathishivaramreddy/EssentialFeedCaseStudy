//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 30/01/21.
//

import Foundation
import XCTest

import EssentialFeed

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        
        super.setUp()
        
        setupStoreBeforeTesting()
    }
    
    override func tearDown() {
        
        super.tearDown()
        
        undoStoreChangeAfterTest()
    }
    
    func test_retreive_emptyOnEmptyCache() {
        
        let sut = makeSUT()
        
        expect(sut: sut, toRetreive: .empty)
    }
    
    func test_retreive_doesNotHaveSideEffectOnEmptyCache() {
        
        let sut = makeSUT()
                
        expect(sut: sut, toRetreive: .empty)
        expect(sut: sut, toRetreive: .empty)
    }
    
    func test_retreiveAfterInsertion_returnsItemsCacheInserted() {
        
        let sut = makeSUT()
        
        let items = uniqueItems().localItems
        let timeStamp = Date()
        
        insert(sut: sut, feed: items, timeStamp: timeStamp)
        
        expect(sut: sut, toRetreive: .found(feedImage: items, timeStamp: timeStamp))

    }
    
    func test_twiceretreiveAfterInsertion_hasNoSideAffectsOnNonEmptyCache() {
        
        let sut = makeSUT()
        
        let items = uniqueItems().localItems
        let timeStamp = Date()
        
        insert(sut: sut, feed: items, timeStamp: timeStamp)
    
        expect(sut: sut, toRetreive: .found(feedImage: items, timeStamp: timeStamp))
        expect(sut: sut, toRetreive: .found(feedImage: items, timeStamp: timeStamp))

    }
    
    func test_retreive_deliversErrorOnError() {
        
        let sut = makeSUT()
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
                
        expect(sut: sut, toRetreive: .failure(anyNSError()))
    }
    
    func test_retreive_hasNoSideEffectsOnError() {
        
        let storeUrl = testSpecificStoreURL()
        let sut = makeSUT(storeUrl: storeUrl)
        
        try! "invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
                
        expect(sut: sut, toRetreive: .failure(anyNSError()))
        expect(sut: sut, toRetreive: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedValues() {
        
        let sut = makeSUT()
        
        let insertionError = insert(sut: sut, feed: uniqueItems().localItems, timeStamp: Date())
        XCTAssertNil(insertionError)
        
        let latestItems = uniqueItems().localItems
        let latestDate = Date()
        let latestInsertionError = insert(sut: sut, feed:latestItems, timeStamp: latestDate)
        XCTAssertNil(latestInsertionError)
        
        expect(sut: sut, toRetreive: .found(feedImage: latestItems, timeStamp: latestDate))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        
        let storeUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("invalid://store")
        let sut = makeSUT(storeUrl: storeUrl)
        
        let insertionError = insert(sut: sut, feed: uniqueItems().localItems, timeStamp: Date())
        XCTAssertNotNil(insertionError)
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        
        let sut = makeSUT()
        
        XCTAssertNil(delete(sut: sut))
        }
    
    func test_delete_deletesPreviouslyInsertedCache() {
        
        let sut = makeSUT()
        
        let insertionError = insert(sut: sut, feed: uniqueItems().localItems, timeStamp: Date())
        XCTAssertNil(insertionError)
        
        XCTAssertNil(delete(sut: sut))
        
        expect(sut: sut, toRetreive: .empty)
    }
    
    func test_delete_deliversDeletionErrorOnNoPermission() {
        
        let noDeletionPermissionStoreUrl = cachesDirectory()
        let sut = makeSUT(storeUrl: noDeletionPermissionStoreUrl)
        
        XCTAssertNotNil(delete(sut: sut))
        }
    
    //Mark: Helpers
    
    private func makeSUT(storeUrl: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        
        let sut = CodableFeedStore(storeUrl: storeUrl ?? testSpecificStoreURL())
        trackMemoryLeak(sut,file: file, line: line)
        return sut
    }
    
    func test_sideEffects_runSerially() {
        
        let sut = makeSUT()
        
        var operations = [XCTestExpectation]()
        let operation1 = expectation(description: "Insertion Operation")
        sut.insert(items: uniqueItems().localItems, currentDate: Date()) { _ in
            
            operations.append(operation1)
            operation1.fulfill()
        }
        
        let operation2 = expectation(description: "Deletion Operation")
        
        sut.deleteCacheFeed { _ in
            
            operations.append(operation2)
            operation2.fulfill()
        }
        
        let operation3 = expectation(description: "Insertion Operation")
        sut.insert(items: uniqueItems().localItems, currentDate: Date()) { _ in
            
            operations.append(operation3)
            operation3.fulfill()
        }
        
        wait(for: [operation1,operation2,operation3], timeout: 5.0)
        XCTAssertEqual([operation1, operation2,operation3], operations,"Expectation side effects to run serially")
    }
    
    @discardableResult
    private func insert(sut: FeedStore, feed: [LocalFeedImage], timeStamp: Date) -> Error? {
        
        let exp = expectation(description: "Wait for retreive")
        var receivedError: Error?
        sut.insert(items: feed, currentDate: timeStamp) { insertionError in
            
            receivedError = insertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    @discardableResult
    private func delete(sut: FeedStore) -> Error?{
        
        let exp = expectation(description: "Waiting for delete expectation to complete")
        
        var receivedError: Error?
        sut.deleteCacheFeed { deletionError in
            
            receivedError = deletionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func expect(sut: FeedStore, toRetreive expectedResult: RetrievedFeedCacheResult) {
        
        let exp = expectation(description: "Wait for retreive")
        
        sut.retrieve { receivedResult in
            switch (expectedResult, receivedResult) {
                
                case (.empty, .empty)
                     , (.failure, .failure):
                    break
                case let (.found(firstFeedItems, firstTime), .found(secondFeedItems, secondTime)):
                    XCTAssertEqual(firstFeedItems, secondFeedItems)
                    XCTAssertEqual(firstTime, secondTime)
                    
                default:
                    XCTFail("Expected \( expectedResult) but got \(receivedResult)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func setupStoreBeforeTesting() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func undoStoreChangeAfterTest() {
        deleteStoreArtifacts()
    }
    
    private func cachesDirectory() -> URL {
        
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
