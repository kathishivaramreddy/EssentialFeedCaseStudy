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
        
        let feedViewModel = FeedRefreshViewModel(loader: loader)
        
        let refereshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(refreshViewController: refereshController)
        
        feedViewModel.onFeedLoad = adaptFeedModelToFeedImageCellController(forwardTo: feedViewController, with: imageLoader)
        
        
        return feedViewController
    }
    
    private static func adaptFeedModelToFeedImageCellController(forwardTo controller: FeedViewController, with imageLoader: FeedImageLoader)
    -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            
            controller?.feedModel = feed.map({ (feedImage) in
                
                FeedImageCellController(imageLoader: imageLoader, cellModel: feedImage)
            })
        }
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
