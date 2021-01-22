//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 21/01/21.
//

import Foundation
import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {

        let url = URL(string: "https://a-example.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {

        let url = URL(string: "https://a-example.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_load_deliversErroronClientError() {
        
        let url = URL(string: "https://a-example.com")!
        let (sut, client) = makeSUT(url: url)
        
        expect(sut: sut, withCapturedError: .connectivity) {
            
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            
            client.complete(withError: clientError, at: 0)
        }
    }
    
    func test_load_deliversErroronNon200HttpResponse() {
        
        let url = URL(string: "https://a-example.com")!
        let (sut, client) = makeSUT(url: url)
        
        
        let samples = [199, 201, 300, 400 ,500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut: sut, withCapturedError: .invalidResponse) {
                
                client.complete(withStatus: code, at: index)
            }
        }
    }
    
    func test_load_deliversErroron200HttpResponseWithInvalidJSON() {
        
        let url = URL(string: "https://a-example.com")!
        let (sut, client) = makeSUT(url: url)
        
        expect(sut: sut, withCapturedError: .invalidResponse) {
            
            let invalidJson = Data("Invalid JSON".utf8)
            
            client.complete(withStatus: 200, data: invalidJson)
        }
    }
    
    
    func test_load_deliversNoItem200HttpResponseWithEmptyListJSON() {
        
        let url = URL(string: "https://a-example.com")!
        let (sut, client) = makeSUT(url: url)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        
        sut.load {
            
            capturedResults.append($0)
        }
        
        client.complete(withStatus: 200, data: Data("{ \"items\": []}".utf8))
        
        XCTAssertEqual(capturedResults, [.success([])])
    }
    
    //Mark:- Helper
    
    private func makeSUT(url: URL = URL(string: "https://a-example.com")!) -> (sut: RemoteFeedLoader, cleint: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut,client)
    }
    
    private func expect(sut: RemoteFeedLoader, withCapturedError: RemoteFeedLoader.Error, action: () -> Void,  file: StaticString = #filePath, line: UInt = #line) {
        
        var capturedResults =  [RemoteFeedLoader.Result]()
        
       
        sut.load { capturedResults.append($0) }
                
        action()
        
        XCTAssertEqual(capturedResults, [.failure(withCapturedError)], file: file, line: line)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
                
        private var messages = [(url: URL, completion: (HTTPClientResponse) -> Void)]()
        
        var requestedURLs: [URL] {
            
            return messages.map{ $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
            
            messages.append((url, completion))
        }
        
        func complete(withError: Error, at index: Int = 0) {
            
            messages[index].completion(.failure(withError))
        }
        
        func complete(withStatus code: Int, data: Data =  Data(),at index: Int = 0) {
            
            let response = HTTPURLResponse(
                url: self.requestedURLs[index]
                , statusCode: code
                , httpVersion: nil
                , headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }

}
