//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by ShivaRamReddy on 03/03/21.
//

import Foundation
import XCTest

class FeedViewController: UIViewController {
    
    private var loader: FeedViewControllerTests.LoaderSpy?
    convenience init(loader: FeedViewControllerTests.LoaderSpy) {
        
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loader?.loadFeed()
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
    
    class LoaderSpy {
        
        private(set) var loadedCellCount = 0
        
        func loadFeed() {
            
            loadedCellCount = 1
        }
    }
}
