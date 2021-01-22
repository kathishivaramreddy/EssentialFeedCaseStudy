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
            
        }.resume()
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
    
    func test_getFromURL_resumesDataTaskWithUrl() {
        
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let url = URL(string: "https://any-url.com")!
        
        var task = ResumeSessionDataTask()
        
        session.stub(for: url, dataTask: task)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    //Mark:- Helper
    
    private class URLSessionSpy: URLSession {
        
        var capturedUrls = [URL]()
        
        var stubs = [URL: URLSessionDataTask]()
        
        func stub(for url: URL, dataTask: URLSessionDataTask) {
            
            stubs[url] = dataTask
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            
            capturedUrls.append(url)
            return stubs[url] ?? MockSessionDataTask()
        }
    }
    
    private class MockSessionDataTask: URLSessionDataTask {
        
        override func resume() {
            
        }
    }
    
    private class ResumeSessionDataTask: URLSessionDataTask {
        
        var resumeCallCount = 0
        
        override func resume() {
            
            resumeCallCount += 1
        }
    }
}
