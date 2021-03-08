//
//  FeedRefreshPresenter.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 08/03/21.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
    
    func display(isLoading: Bool)
}

protocol FeedView {
    
    func display(feedImages: [FeedImage])
}

final class FeedRefreshPresenter {
    
    private var loader: FeedLoader?
    
    init(loader: FeedLoader) {
        
        self.loader = loader
    }
    
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    public func loadFeed() {
        
        loadingView?.display(isLoading: true)
        loader?.load{ [weak self] result in
            
            switch result {
                
                case let .success(feed):
                    self?.feedView?.display(feedImages: feed)
                case .failure:
                    break
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
