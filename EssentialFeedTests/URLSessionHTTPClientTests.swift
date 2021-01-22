//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 23/01/21.
//

import Foundation
import XCTest

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        
        self.session = session
    }
    
    func get(from url: URL) {
        
        self.session.dataTask(with: url) { (_, _, _) in
            
        }
    }
    
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_createsDataTaskWithUrl() {
        
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let url = URL(string: "https://any-url.com")!
        
        
        
        sut.get(from: url)
        
        XCTAssertEqual(session.capturedUrls, [url])
    }
    
    private class URLSessionSpy: URLSession {
        
        var capturedUrls = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            
            capturedUrls.append(url)
            return MockSessionDataTask()
        }
    }
    
    private class MockSessionDataTask: URLSessionDataTask {
        
        
    }
}
