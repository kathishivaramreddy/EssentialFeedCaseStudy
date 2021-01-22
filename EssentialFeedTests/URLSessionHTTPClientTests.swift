//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 23/01/21.
//

import Foundation
import XCTest

import EssentialFeed

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        
        self.session = session
    }
    
    func get(from url: URL, completionHandler: @escaping (HTTPClientResponse) -> Void) {
        
        self.session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                
                completionHandler(.failure(error))
            }
            
        }.resume()
    }
    
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithUrl() {
        
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let url = URL(string: "https://any-url.com")!
        
        var task = ResumeSessionDataTask()
        
        session.stub(for: url, dataTask: task)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let error = NSError(domain: "any error", code: 0)
        
        let url = URL(string: "https://any-url.com")!
        
        
        session.stub(for: url, error: error)
        
        let exp = expectation(description: "any expectation")
        
        sut.get(from: url) { result in
            
            switch result {
                
                case let .failure(recievedError as NSError):
                    XCTAssertEqual(recievedError, error)
                default:
                    XCTFail("expected failure but got \(result)")
            }
            exp.fulfill()
        }
        
//        task.
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //Mark:- Helper
    
    private class URLSessionSpy: URLSession {
                
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(for url: URL, dataTask: URLSessionDataTask = MockSessionDataTask(), error: Error? = nil) {
            
            stubs[url] = Stub(task: dataTask, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            
            guard let stub = stubs[url] else { fatalError("no stubs") }
            
            completionHandler(nil,nil,stub.error)
            return stub.task ?? MockSessionDataTask()
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
