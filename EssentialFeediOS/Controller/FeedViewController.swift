//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 04/03/21.
//

import Foundation
import UIKit
import EssentialFeed

final public class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(loader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        
        let refereshController = FeedRefreshViewController(loader: loader)
        let feedViewController = FeedViewController(refreshViewController: refereshController)
        
        refereshController.onRefresh = { [weak feedViewController] feed in
            
            feedViewController?.feedModel = feed.map({ (feedImage) in
                
                FeedImageCellController(imageLoader: imageLoader, cellModel: feedImage)
            })
        }
        
        return feedViewController
    }
}

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
        
    var refereshController: FeedRefreshViewController?
        
    var feedModel = [FeedImageCellController]() {
        
        didSet {
            
            self.tableView?.reloadData()
        }
    }
    
    convenience init(refreshViewController: FeedRefreshViewController) {
        
        self.init()
        self.refereshController = refreshViewController
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        refreshControl = refereshController?.refreshControl
        refereshController?.load()
        
        tableView.prefetchDataSource = self
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return feedModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        return self.getCellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        self.removeCellController(forIndexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { (indexPath) in
                        
            self.getCellController(forRowAt: indexPath).preLoad()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { (indexPath) in
            
            self.removeCellController(forIndexPath: indexPath)
        }
    }
    
    private func removeCellController(forIndexPath indexPath: IndexPath) {
        
        self.getCellController(forRowAt: indexPath).cancel()
    }
    
    private func getCellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
            return feedModel[indexPath.row]
        }
}
