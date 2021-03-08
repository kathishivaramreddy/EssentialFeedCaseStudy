//
//  FeedRefreshPresenter.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 08/03/21.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    
    let isLoading: Bool
}

protocol FeedLoadingView {
    
    func display(viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    
    let feedImages: [FeedImage]
}

protocol FeedView {
    
    func display(viewModel: FeedViewModel)
}

final class FeedRefreshPresenter {
    
    private var loader: FeedLoader?
    
    init(loader: FeedLoader) {
        
        self.loader = loader
    }
    
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    public func loadFeed() {
        
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
        loader?.load{ [weak self] result in
            
            switch result {
                
                case let .success(feed):
                    self?.feedView?.display(viewModel: FeedViewModel(feedImages: feed))
                case .failure:
                    break
            }
            self?.loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
        }
    }
}
