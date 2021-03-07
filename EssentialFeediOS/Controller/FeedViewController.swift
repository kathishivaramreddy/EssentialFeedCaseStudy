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
    private var feedModel = [FeedImage]() {
        didSet {
            
            self.tableView?.reloadData()
        }
    }
    var task = [Int: FeedImageTaskLoader]()
    
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
        
        let cellModel = feedModel[indexPath.row]
        
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.descriptionLabel.text = cellModel.description
        cell.locationLabel.text = cellModel.location
        
        cell.feedImageContainer.startShimmering()
        cell.feedRetryButton.isHidden = true
        cell.feedImageView.image = nil
        
        let loadImage = { [weak self, weak cell] in
            
            guard let self = self else { return }
            
            self.task[indexPath.row] = self.imageLoader?.loadImage(with: cellModel.imageURL) { [weak cell] result in
                
                if let data = try? result.get(), let image = UIImage(data: data) {
                    
                    cell?.feedImageView.image = image
                } else {
                    
                    cell?.feedRetryButton.isHidden = false
                }
                cell?.feedImageContainer.stopShimmering()
            }
        }
        cell.onRetry = loadImage
        
        loadImage()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        task[indexPath.row]?.cancel()
        task[indexPath.row] = nil
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { (indexPath) in
            
            let cellModel = feedModel[indexPath.row]
            
            self.task[indexPath.row] = self.imageLoader?.loadImage(with: cellModel.imageURL, completion: { _ in
            })
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { (indexPath) in
            
            task[indexPath.row]?.cancel()
            task[indexPath.row] = nil
        }
    }
    
}
