//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 04/03/21.
//

import Foundation
import UIKit
import EssentialFeed

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private var imageLoader: FeedImageLoader?
    
    private var refereshController: FeedRefreshViewController?
    
    private var cellControllers = [IndexPath: FeedImageCellController]()
    
    private var feedModel = [FeedImage]() {
        
        didSet {
            
            self.tableView?.reloadData()
        }
    }
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageLoader) {
        
        self.init()
        self.refereshController = FeedRefreshViewController(loader: loader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        refreshControl = refereshController?.refreshControl
        
        tableView.prefetchDataSource = self
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        refereshController?.onRefresh = { [weak self] feed in
            
            self?.feedModel = feed
        }
        
        refereshController?.load()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return feedModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cellController = createCellController(forRowAt: indexPath)
        return cellController.view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        self.removeCellController(forIndexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { (indexPath) in
                        
            let cellController = createCellController(forRowAt: indexPath)
            cellController.preLoad()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { (indexPath) in
            
            self.removeCellController(forIndexPath: indexPath)
        }
    }
    
    private func removeCellController(forIndexPath indexPath: IndexPath) {
        
        self.cellControllers[indexPath] = nil
    }
    
    private func createCellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
            let cellModel = feedModel[indexPath.row]
            let cellController = FeedImageCellController(imageLoader: self.imageLoader!, cellModel: cellModel)
            cellControllers[indexPath] = cellController
            return cellController
        }
}
