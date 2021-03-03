//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by ShivaRamReddy on 03/03/21.
//

import Foundation
import XCTest
import EssentialFeed

class FeedViewController: UIViewController {
    
    private var loader: FeedLoader?
    convenience init(loader: FeedLoader) {
        
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loader?.load{ _ in }
    }
}

class FeedViewControllerTests: XCTestCase {
 
    func test_init_doesNotLoadFeed() {
        
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadedCellCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadedCellCount, 1)
    }
    
    class LoaderSpy: FeedLoader {
        
        private(set) var loadedCellCount = 0
        
        func load(completion: @escaping (LoadFeedResult) -> Void) {
            
            loadedCellCount += 1
        }
    }
}
