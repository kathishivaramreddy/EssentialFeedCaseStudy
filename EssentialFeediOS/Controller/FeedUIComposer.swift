//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 08/03/21.
//

import Foundation
import EssentialFeed
import UIKit

final public class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(loader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        
        let feedViewModel = FeedRefreshViewModel(loader: loader)
        
        let refereshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(refreshViewController: refereshController)
        
        feedViewModel.onFeedLoad = adaptFeedModelToFeedImageCellController(forwardTo: feedViewController, with: imageLoader)
        
        
        return feedViewController
    }

    private static func adaptFeedModelToFeedImageCellController(forwardTo controller: FeedViewController, with imageLoader: FeedImageLoader)
    -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            
            controller?.feedModel = feed.map({ (feedImage) in
                
                FeedImageCellController(cellViewModel: FeedImageCellViewModel(cellModel: feedImage, imageLoader: imageLoader, imageTransformer: UIImage.init))
            })
        }
    }
}
