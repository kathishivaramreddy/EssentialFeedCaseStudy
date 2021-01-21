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
        
        var capturedErrors =  [RemoteFeedLoader.Error]()
        
       
        sut.load {
            
            capturedErrors.append($0)
        }
        
        let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
        
        client.complete(withError: clientError, at: 0)
        
        XCTAssertEqual(capturedErrors, [RemoteFeedLoader.Error.connectivity])
    }
    
    func test_load_deliversErroronNon200HttpResponse() {
        
        let url = URL(string: "https://a-example.com")!
        let (sut, client) = makeSUT(url: url)
        
        var capturedErrors =  [RemoteFeedLoader.Error]()
        
       
        sut.load {
            
            capturedErrors.append($0)
        }
        
        client.complete(withStatus: 400)
        
        XCTAssertEqual(capturedErrors, [.invalidResponse])
    }
    
    //Mark:- Helper
    
    private func makeSUT(url: URL = URL(string: "https://a-example.com")!) -> (sut: RemoteFeedLoader, cleint: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut,client)
    }
    
    private class HTTPClientSpy: HTTPClient {
                
        private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        
        var requestedURLs: [URL] {
            
            return messages.map{ $0.url }
        }

        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            
            messages.append((url, completion))
        }
        
        func complete(withError: Error, at index: Int = 0) {
            
            messages[index].completion(withError, nil)
        }
        
        func complete(withStatus code: Int, at index: Int = 0) {
            
            let response = HTTPURLResponse(
                url: self.requestedURLs[index]
                , statusCode: code
                , httpVersion: nil
                , headerFields: nil)
            messages[index].completion(nil, response)
        }
    }

}
