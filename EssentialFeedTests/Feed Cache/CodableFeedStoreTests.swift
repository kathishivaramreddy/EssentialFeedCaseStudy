//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 30/01/21.
//

import Foundation
import XCTest

import EssentialFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        
        let items: [CodableFeedImage]
        let timeStamp: Date
        
        var local: [LocalFeedImage] {
            
            return items.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        
        private let id: UUID
        private let description: String?
        private let location: String?
        private let imageURL: URL
        
        public init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.imageURL = image.imageURL
        }
        
        var local: LocalFeedImage {
            
            return LocalFeedImage(id: id, description: description, location: location, imageURL: imageURL)
        }
    }
    
    private let storeUrl: URL
    
    init(storeUrl: URL) {
        
        self.storeUrl = storeUrl
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        
        guard let data = try? Data(contentsOf: storeUrl) else {
            
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        
        let decoded = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(feedImage: decoded.local, timeStamp: decoded.timeStamp))
    }
    
    func insert(items: [LocalFeedImage], currentDate: Date, completion: @escaping FeedStore.InsertionCompletion) {
        
        let encoder = JSONEncoder()
        let cache = Cache(items: items.map { CodableFeedImage($0)}, timeStamp: currentDate)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeUrl)
        
        completion(nil)
    }
}

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
        
        let exp = expectation(description: "Wait for retreive")
        
        sut.retrieve { result in
            
            switch result {
                
                case .empty:
                    break
                default:
                    XCTFail("Expect empty but got \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retreive_doesNotHaveSideEffectOnEmptyCache() {
        
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for retreive")
        
        sut.retrieve { firstResult in
            
            sut.retrieve { secondresult in
                
                switch (firstResult, secondresult) {
                    
                    case (.empty, .empty):
                        break
                    default:
                        XCTFail("Expect empty result twice on retreiving twice but got \(firstResult) \(secondresult)")
                }
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retreiveAfterInsertion_returnsItemsCacheInserted() {
        
        let sut = makeSUT()
        
        let items = uniqueItems().localItems
        let timeStamp = Date()
        
        let exp = expectation(description: "Wait for retreive")
        
        sut.insert(items: items, currentDate: timeStamp) { insertionError in
            
            XCTAssertNil(insertionError)
            
            sut.retrieve { result in
                
                switch result {
                    
                    case let .found(feedItems, time):
                        XCTAssertEqual(feedItems, items)
                        XCTAssertEqual(time, timeStamp)
                    default:
                        XCTFail("Expected inserted feed items but got \(result)")
                }
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_twiceretreiveAfterInsertion_hasNoSideAffectsOnNonEmptyCache() {
        
        let sut = makeSUT()
        
        let items = uniqueItems().localItems
        let timeStamp = Date()
        
        let exp = expectation(description: "Wait for retreive")
        
        sut.insert(items: items, currentDate: timeStamp) { insertionError in
            
            XCTAssertNil(insertionError)
            
            sut.retrieve { firstResult in
                
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                        
                        case let (.found(firstFeedItems, firstTime), .found(secondFeedItems, secondTime)):
                            XCTAssertEqual(firstFeedItems, items)
                            XCTAssertEqual(firstTime, timeStamp)
                            XCTAssertEqual(secondFeedItems, items)
                            XCTAssertEqual(secondTime, timeStamp)
                        default:
                            XCTFail("Expected same value to be retreived but \(firstResult) \(firstResult)")
                    }
                }
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //Mark: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        
        let sut = CodableFeedStore(storeUrl: testSpecificStoreURL())
        trackMemoryLeak(sut,file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
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
}
