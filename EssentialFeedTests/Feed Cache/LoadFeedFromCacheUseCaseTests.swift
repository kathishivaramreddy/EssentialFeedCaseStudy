//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 28/01/21.
//

import Foundation
import XCTest

import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotRecieveMessage() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessage, [])
    }
    
    func test_load_requestCacheRetreiva() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessage, [.retrieve])
    }
    
    func test_load_deliverErrorOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, withCompletion: .failure(retrievalError)) {
            
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliverEmptyCacheOnEmptyCacheAndSuccessfulRetrieval() {

        let (sut, store) = makeSUT()
        
        expect(sut, withCompletion: .success([])) {
            
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliverCacheImageOnLessThanSevenDaysCache() {
        
        let currentDate = Date()
        
        let (sut, store) = makeSUT(currentDate: { currentDate })
        
        let feed = uniqueItems()
        
        let lessThanSevenDays = currentDate.adding(days: -7).adding(seconds: 1)
        expect(sut, withCompletion: .success(feed.models)) {
            
            store.completeRetrievalWith(localFeed: feed.localItems, timeStamp: lessThanSevenDays)
        }
    }
    
    func test_load_deliverErrorImageOnMoreThanSevenDaysCache() {
        
        let currentDate = Date()
        
        let (sut, store) = makeSUT(currentDate: { currentDate })

        let feed = uniqueItems()
            
        let lessThanSevenDays = currentDate.adding(days: -7)
        expect(sut, withCompletion: .success([])) {
            
            store.completeRetrievalWith(localFeed: feed.localItems, timeStamp: lessThanSevenDays)
        }
    }

    //Marker: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, items: uniqueItems().models, currentDate: currentDate)
        
        trackMemoryLeak(sut, file: file, line: line)
        trackMemoryLeak(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, withCompletion expectedResult: LoadFeedResult, action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Expectation for load")

        sut.load { receivedResult in

            switch (receivedResult, expectedResult) {
                case let (.success(receivedImages), .success(expectedImages)):
                    XCTAssertEqual(receivedImages, expectedImages,file: file, line: line)
                case let (.failure(receivedError), .failure(expectedError)):
                    XCTAssertEqual(receivedError as NSError, expectedError as NSError,file: file, line: line)
                default:
                    XCTFail("Expected \(expectedResult) but got \(receivedResult)",file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
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

extension Date {
    
    func adding(days: Int) -> Date {
        
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        
        return self + seconds
    }
}
