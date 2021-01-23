//
//  XCTest+MemoryLeak.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 23/01/21.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func trackMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        
        addTeardownBlock { [weak instance] in
            
            XCTAssertNil(instance,file: file, line: line)
        }
    }
}
