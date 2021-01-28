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
        
        var receivedError: Error?
        let retrievalError = anyNSError()
        
        let exp = expectation(description: "Expectation for load")
        
        sut.load { result in
            
            switch result {
                
                case let .failure(error):
                    receivedError = error
                default:
                    XCTFail()
            }
            
            exp.fulfill()
        }
        
        store.completeRetrieval(with: retrievalError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    
    func test_load_deliverEmptyCacheOnEmptyCacheAndSuccessfulRetrieval() {

        let (sut, store) = makeSUT()

        var receivedImage: [FeedImage]?

        let exp = expectation(description: "Expectation for load")

        sut.load { result in

            switch result {
                case let .success(images):
                    receivedImage = images
                default:
                    XCTFail("Expected images but got \(result)")
            }
            exp.fulfill()
        }

        store.completeRetrievalWithEmptyCache()

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedImage, [])
    }

    //Marker: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, items: uniqueItems().models, currentDate: currentDate)
        
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
