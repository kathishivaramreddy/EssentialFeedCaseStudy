//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 04/03/21.
//

import Foundation
import UIKit
import EssentialFeed

public protocol FeedImageLoader {
    
    func loadImage(with url: URL)
}

public class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    private var imageLoader: FeedImageLoader?
    
    private var feedModel = [FeedImage]()
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
        
        self.imageLoader?.loadImage(with: cellModel.imageURL)
        return cell
    }
}
