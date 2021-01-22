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
    
    init(session: URLSession = .shared) {
        
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
        
    func test_getFromURL_failsOnRequestError() {
        
        URLProtocolStub.startInterceptingRequests()

        let sut = URLSessionHTTPClient()
        let error = NSError(domain: "any error", code: 0)
        
        let url = URL(string: "https://any-url.com")!
        
        
        URLProtocolStub.stub(for: url, error: error)
        
        let exp = expectation(description: "any expectation")
        
        sut.get(from: url) { result in
            
            switch result {
                
                case let .failure(recievedError as NSError):
                    XCTAssertEqual(recievedError.domain, error.domain)
                    XCTAssertEqual(recievedError.code, error.code)
                default:
                    XCTFail("expected failure but got \(result)")
            }
            exp.fulfill()
        }
                
        wait(for: [exp], timeout: 1.0)
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    //Mark:- Helper
    
    private class URLProtocolStub: URLProtocol {
                
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            
            let error: Error?
        }
        
        static func stub(for url: URL, error: Error? = nil) {
            
            stubs[url] = Stub( error: error)
        }
        
        static func startInterceptingRequests() {
            
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stubs = [:]

        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            
            guard let url = request.url else { return false }
            
            return URLProtocolStub.stubs[url] != nil
            
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            
            return request
        }
        
        override func startLoading() {
            
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return  }
            
            if let error = stub.error {
                
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
}
