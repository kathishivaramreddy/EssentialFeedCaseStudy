//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 30/01/21.
//

import Foundation
import XCTest

import EssentialFeed

class CodableFeedStore {
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    
    func test_retreive_emptyOnEmptyCache() {
        
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for retreive")
        
        sut.retrieve { result in
            
            switch result {
                
                case .empty:
                    break
                default:
                    XCTFail("Expect empty but got \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
