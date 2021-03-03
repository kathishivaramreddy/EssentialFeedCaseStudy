//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by ShivaRamReddy on 03/03/21.
//

import Foundation
import XCTest
import EssentialFeed

class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    convenience init(loader: FeedLoader) {
        
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
    }
    
    @objc func load() {
        
        loader?.load{ [weak self] _ in
            
            self?.refreshControl?.endRefreshing()
        }
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
    
    func test_userIntiatedFeedReload_loadsFeed() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.simulateUserIntiatedReload()
        
        XCTAssertEqual(loader.loadedCellCount, 2)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_loadIndicator_isHiddenWhenFeedIsLoaded() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
        
        loader.successfullyCompletedLodinngFeed()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    func test_userIntiatedFeedReload_showsLoadingIndicator() {
        
        let (sut, _) = makeSUT()
        
        sut.simulateUserIntiatedReload()

        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_loadIndicator_isHiddenWhenuserIntiatedFeedReloadisLoaded() {
        
        let (sut, loader) = makeSUT()
        
        sut.simulateUserIntiatedReload()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
        
        loader.successfullyCompletedLodinngFeed()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    
    class LoaderSpy: FeedLoader {
        
        var loadedCellCount: Int   {
            
            return completions.count
        }
        
        private(set) var completions = [(LoadFeedResult) -> Void]()
        
        func load(completion: @escaping (LoadFeedResult) -> Void) {
            
            completions.append(completion)
        }
        
        func successfullyCompletedLodinngFeed() {
            
            completions[0](.success([]))
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

extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        
        self.allTargets.forEach({ (target) in
            
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}

private extension FeedViewController {
    
    func simulateUserIntiatedReload() {
        
        refreshControl?.simulatePullToRefresh()
    }
}
