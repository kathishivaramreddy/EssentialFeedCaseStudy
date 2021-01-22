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
        
        expect(sut: sut, withCaptured: .failure(.connectivity)) {
            
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            
            client.complete(withError: clientError, at: 0)
        }
    }
    
    func test_load_deliversErroronNon200HttpResponse() {
        
        let url = URL(string: "https://a-example.com")!
        let (sut, client) = makeSUT(url: url)
        
        
        let samples = [199, 201, 300, 400 ,500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut: sut, withCaptured: .failure(.invalidResponse)) {
                
                client.complete(withStatus: code, at: index)
            }
        }
    }
    
    func test_load_deliversErroron200HttpResponseWithInvalidJSON() {
        
        let url = URL(string: "https://a-example.com")!
        let (sut, client) = makeSUT(url: url)
        
        expect(sut: sut, withCaptured: .failure(.invalidResponse)) {
            
            let invalidJson = Data("Invalid JSON".utf8)
            
            client.complete(withStatus: 200, data: invalidJson)
        }
    }
    
    
    func test_load_deliversNoItem200HttpResponseWithEmptyListJSON() {
        
        let url = URL(string: "https://a-example.com")!
        let (sut, client) = makeSUT(url: url)
        
        
        expect(sut: sut, withCaptured: .success([])) {
            
            client.complete(withStatus: 200, data: Data("{ \"items\": []}".utf8))
        }
    }
    
    func test_load_deliversItem200HttpResponseWithValidJSON() {
        
        let url = URL(string: "https://a-example.com")!
        let (sut, client) = makeSUT(url: url)
        
        let item1 = makeItem(id: UUID()
                             , imageURL: URL(string: "https://a-url.com")!)
        
        let item2 = makeItem(id: UUID()
                             , description: "a description"
                             , location: "a location"
                             , imageURL: URL(string: "https://a-url.com")!)
        
        
        expect(sut: sut, withCaptured: .success([item1.model, item2.model])) {
            
            let data = makeJson(withItems: [item1.json, item2.json])
            client.complete(withStatus: 200, data: data)
        }
    }
    
    //Mark:- Helper
    
    private func makeSUT(url: URL = URL(string: "https://a-example.com")!) -> (sut: RemoteFeedLoader, cleint: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut,client)
    }
    
    private func expect(sut: RemoteFeedLoader, withCaptured : RemoteFeedLoader.Result, action: () -> Void,  file: StaticString = #filePath, line: UInt = #line) {
        
        var capturedResults =  [RemoteFeedLoader.Result]()
        
       
        sut.load { capturedResults.append($0) }
                
        action()
        
        XCTAssertEqual(capturedResults, [withCaptured], file: file, line: line)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil , imageURL: URL) -> (model: FeedItem, json: [String: Any]){
        
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = ["id": id.uuidString, "description": description, "location": location, "image": imageURL.absoluteString].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeJson(withItems: [[String: Any]]) -> Data {
        
        let json = ["items": withItems]
        return try! JSONSerialization.data(withJSONObject: json)
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
