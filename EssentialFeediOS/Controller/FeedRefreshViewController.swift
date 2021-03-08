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
    
    var loadFeed: ()  -> Void
    init(loadFeed: @escaping ()  -> Void) {
        
        self.loadFeed = loadFeed
    }
    
    private(set) lazy var refreshControl: UIRefreshControl = loadView()
    
    
    @objc public func load() {
        
        self.loadFeed()
    }
    
    func display(viewModel: FeedLoadingViewModel) {
        
        if viewModel.isLoading {
            
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
