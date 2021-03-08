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
        
        let feedPresenter = FeedRefreshPresenter(loader: loader)
        
        let refereshController = FeedRefreshViewController(feedPresenter: feedPresenter)
        let feedViewController = FeedViewController(refreshViewController: refereshController)
        
        feedPresenter.loadingView = refereshController
        feedPresenter.feedView = FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader)
        
        return feedViewController
    }
    
}


class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private var imageLoader: FeedImageLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageLoader) {
        
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(feedImages: [FeedImage]) {
        
        controller?.feedModel = feedImages.map({ (feedImage) in
            
            FeedImageCellController(cellViewModel: FeedImageCellViewModel(cellModel: feedImage, imageLoader: imageLoader, imageTransformer: UIImage.init))
        })
    }
}

