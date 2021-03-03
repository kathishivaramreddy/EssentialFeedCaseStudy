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
        
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadedCellCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadedCellCount, 1)
    }
    
    class LoaderSpy: FeedLoader {
        
        private(set) var loadedCellCount = 0
        
        func load(completion: @escaping (LoadFeedResult) -> Void) {
            
            loadedCellCount += 1
        }
    }
    
    //MARK: Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackMemoryLeak(loader,file: file,line: line)
        trackMemoryLeak(sut,file: file,line: line)
        
        return (sut, loader)
    }
}
