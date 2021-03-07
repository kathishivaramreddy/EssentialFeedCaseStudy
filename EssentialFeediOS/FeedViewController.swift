//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 04/03/21.
//

import Foundation
import UIKit
import EssentialFeed

public protocol FeedImageTaskLoader {
    
    func cancel()
}

public protocol FeedImageLoader {
    
    typealias Result = Swift.Result<Data, Error>
    
    func loadImage(with url: URL, completion: @escaping (Result) -> Void) -> FeedImageTaskLoader
}

public class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    private var imageLoader: FeedImageLoader?
    
    private var feedModel = [FeedImage]()
    var task = [Int: FeedImageTaskLoader]()
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageLoader) {
        
        self.init()
        self.loader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load{ [weak self] result in
            
            switch result {
                
                case let .success(feed):
                    self?.feedModel = feed
                    self?.tableView.reloadData()
                    
                case .failure:
                    break
            }
            self?.refreshControl?.endRefreshing()
        }
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
        task[indexPath.row] = self.imageLoader?.loadImage(with: cellModel.imageURL) { [weak cell] result in
            
            if let data = try? result.get() {
                
                cell?.feedImageView.image = UIImage(data: data) ?? nil
            } else {
                
                cell?.feedRetryButton.isHidden = false
            }
            cell?.feedImageContainer.stopShimmering()
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        task[indexPath.row]?.cancel()
        task[indexPath.row] = nil
    }
}
