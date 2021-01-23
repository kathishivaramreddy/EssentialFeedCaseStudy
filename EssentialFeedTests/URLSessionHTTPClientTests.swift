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
    
    struct UnexpectedValueRepresentationError: Error {}
    
    func get(from url: URL, completionHandler: @escaping (HTTPClientResponse) -> Void) {
        
        self.session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                
                completionHandler(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                
                completionHandler(.success(data, response))
            } else {
                
                completionHandler(.failure(UnexpectedValueRepresentationError()))
            }
        }.resume()
    }
    
}

class URLSessionHTTPClientTests: XCTestCase {
    
    
    override func setUp() {
        
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_requestsWithGivenURL() {
        
        let url = self.anyURL()
        let exp = expectation(description: "given expectation")
        
        URLProtocolStub.observeRequest { request in
            
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { (_) in }
        
        wait(for: [exp], timeout: 1.0)
    }
        
    func test_getFromURL_failsOnRequestError() {
        
        let error = anyNSError()
        
        guard let receivedError = resultErrorFor(data: nil, response: nil, error: error) as? NSError else {
            
            XCTFail()
            return
        }
        
        XCTAssertEqual(receivedError.domain, error.domain)
        XCTAssertEqual(receivedError.code, error.code)
    }
    
    func test_getFromURL_failsOnAllInvalidValues() {
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHttpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedsWithHttpURLResponseWithData() {
        
        let response = nonHttpURLResponse()
        let data = anyData()
        
        URLProtocolStub.stub(data: data, response: response, error: nil)
        
        let exp = expectation(description: "any expectation")
        
        makeSUT().get(from: anyURL()) { (result) in
            
            switch result {
                
                case let .success(receivedData, receivedResponse):
                    
                    XCTAssertEqual(receivedData, data)
                    XCTAssertEqual(receivedResponse.url, response.url)
                    XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
                default:
                    XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_succeedsWithHttpURLResponseWithEmptyData() {
        
        let response = nonHttpURLResponse()
        
        URLProtocolStub.stub(data: nil, response: response, error: nil)
        
        let exp = expectation(description: "any expectation")
        
        makeSUT().get(from: anyURL()) { (result) in
            
            switch result {
                
                case let .success(receivedData, receivedResponse):
                    
                    let emptyData = Data()
                    XCTAssertEqual(receivedData, emptyData)
                    XCTAssertEqual(receivedResponse.url, response.url)
                    XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
                default:
                    XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //Mark:- Helper
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        
        let sut = URLSessionHTTPClient()
        trackMemoryLeak(sut,file: file,line: line)
        return sut
    }
    
    private func anyNSError() -> NSError {
        
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
    private func anyData() -> Data {
        
        Data("anyData".utf8)
    }
    
    private func nonHttpURLResponse() -> HTTPURLResponse {
        
        HTTPURLResponse(url: anyURL(), statusCode: 0, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonURLResponse() -> URLResponse {
        
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let sut = makeSUT(file: file,line: line)
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "any expectation")
        
        var receivedError: Error?
        
        sut.get(from: self.anyURL()) { result in
            
            switch result {
                
                case let .failure(error):
                    receivedError = error
                default:
                    XCTFail("expected failure but got \(result)",file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
    }
    
    private func anyURL() -> URL {
        
        URL(string: "https://any-url.com")!
    }
    
    private class URLProtocolStub: URLProtocol {
                
        private static var stub: Stub?
        
        static var requestObserver: ((URLRequest) -> Void)?
        
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
            requestObserver = nil
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            
            URLProtocolStub.requestObserver?(request)
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
