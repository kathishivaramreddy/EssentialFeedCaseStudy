//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 07/03/21.
//

import Foundation
import UIKit
import EssentialFeed

final public class FeedRefreshViewController: NSObject {
    
    private var loader: FeedLoader?
    
    init(loader: FeedLoader) {
        
        self.loader = loader
    }
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        
       let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        
        return refreshControl
    }()
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc public func load() {
        
        refreshControl.beginRefreshing()
        loader?.load{ [weak self] result in
            
            switch result {
                
                case let .success(feed):
                    self?.onRefresh?(feed)
                    
                case .failure:
                    break
            }
            self?.refreshControl.endRefreshing()
        }
    }
}
