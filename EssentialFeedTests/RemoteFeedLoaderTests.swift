//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 21/01/21.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    init(url: URL, client: HTTPClient) {
        
        self.url = url
        self.client = client
    }
    
    func load() {
        
        client.get(from: self.url)
    }
}

protocol HTTPClient {
    
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?

    func get(from url: URL) {
        
        self.requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let client = HTTPClientSpy()
        let url = URL(string: "https://a-example.com")!
        
        let _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {

        let client = HTTPClientSpy()
        let url = URL(string: "https://a-example.com")!
        let sut = RemoteFeedLoader(url: url, client: client)


        sut.load()

        XCTAssertNotNil(client.requestedURL, "https://a-example.com")
    }
}
