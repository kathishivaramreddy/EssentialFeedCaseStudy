//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 07/03/21.
//

import Foundation
import UIKit

final class FeedRefreshViewController: NSObject {
    
    private var feedRefreshViewModel: FeedRefreshViewModel?
    
    init(viewModel: FeedRefreshViewModel) {
        
        self.feedRefreshViewModel = viewModel
    }
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        
       let refreshControl = UIRefreshControl()
        
        bind(view: refreshControl)
            
        return refreshControl
    }()
    
    
    @objc public func load() {
        
        feedRefreshViewModel?.onChange = { [weak self] (viewModel) in
            
            if viewModel.isLoading {
                
                self?.refreshControl.beginRefreshing()
            } else {
                
                self?.refreshControl.endRefreshing()
            }
        }
        
        self.feedRefreshViewModel?.loadFeed()
    }
    
    private func bind(view: UIRefreshControl) {
        
        feedRefreshViewModel?.onChange = { [weak self] (viewModel) in
            
            if viewModel.isLoading {
                
                self?.refreshControl.beginRefreshing()
            } else {
                
                self?.refreshControl.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(load), for: .valueChanged)

    }
}
