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
        
        
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
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
                
        private static var stub: Stub?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            URLProtocolStub.stub = nil

        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            
            return true
            
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            
            return request
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
}
