//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 07/03/21.
//

import Foundation
import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    
    private var feedPresenter: FeedRefreshPresenter?
    
    init(feedPresenter: FeedRefreshPresenter) {
        
        self.feedPresenter = feedPresenter
    }
    
    private(set) lazy var refreshControl: UIRefreshControl = loadView()
    
    
    @objc public func load() {
        
        self.feedPresenter?.loadFeed()
    }
    
    func display(isLoading: Bool) {
        
        if isLoading {
            
            self.refreshControl.beginRefreshing()
        } else {
            
            self.refreshControl.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        return refreshControl
    }
}
