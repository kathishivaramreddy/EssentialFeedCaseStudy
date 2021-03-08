//
//  FeedRefreshViewModel.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 08/03/21.
//

import Foundation
import EssentialFeed

final class FeedRefreshViewModel {
    
    private var loader: FeedLoader?
    
    init(loader: FeedLoader) {
        
        self.loader = loader
    }
    
    
    //Observer
    var onStateLoadChange: ((Bool) -> Void)?
    
    //Accessor to view for state
    
    var onFeedLoad: (([FeedImage]) -> Void)?

    public func loadFeed() {
        
        onStateLoadChange?(true)
        loader?.load{ [weak self] result in
            
            switch result {
                
                case let .success(feed):
                    self?.onFeedLoad?(feed)
                case .failure:
                    break
            }
            self?.onStateLoadChange?(false)
        }
    }
}
